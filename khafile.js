const fs = require("fs");
const path = require("path");
const verbose = process.verbose;

function clearDirectory(directory) {
    const files = fs.readdirSync(directory);

    files.forEach((file) => {
        const filePath = path.join(directory, file);
        const stat = fs.statSync(filePath);

        if (stat.isDirectory()) {
            clearDirectory(filePath);
            fs.rmdirSync(filePath);
        } else {
            fs.unlinkSync(filePath);
        }
    });
}

function copyDirectories(srcDir, destDir) {
    const files = fs.readdirSync(srcDir);
    files.forEach((file) => {
        const currentPath = path.join(srcDir, file);
        const targetPath = path.join(destDir, file);
        if (fs.statSync(currentPath).isDirectory()) {
            if (!fs.existsSync(targetPath)) {
                fs.mkdirSync(targetPath, { recursive: true });
            }
            copyDirectories(currentPath, targetPath);
        }
    });
}

function ensureUnsafeEvalHtml5(buildDir) {
    const indexPath = path.join(buildDir, "index.html");
    if (!fs.existsSync(indexPath)) return;
    let html = fs.readFileSync(indexPath, "utf8");
    const cspRegex = /<meta\s+http-equiv="Content-Security-Policy"\s+content="([^"]*)">/i;
    const match = html.match(cspRegex);
    if (!match) return;
    let content = match[1];
    if (!content.includes("script-src")) return;
    if (content.includes("'unsafe-eval'")) return;
    content = content.replace(/script-src\s+'self'/i, "script-src 'self' 'unsafe-eval'");
    html = html.replace(cspRegex, `<meta http-equiv="Content-Security-Policy" content="${content}">`);
    fs.writeFileSync(indexPath, html);
}

function ensureElectronReloadBridge(buildDir) {
    const electronPath = path.join(buildDir, "electron.js");
    if (fs.existsSync(electronPath)) {
        let electronJs = fs.readFileSync(electronPath, "utf8");
        if (!electronJs.includes("reload-window")) {
            electronJs += "\n\nelectron.ipcMain.on('reload-window', () => {\n\tif (mainWindow != null)\n\t\tmainWindow.webContents.reloadIgnoringCache();\n});\n";
            fs.writeFileSync(electronPath, electronJs);
        }
    }

    const preloadPath = path.join(buildDir, "preload.js");
    if (fs.existsSync(preloadPath)) {
        let preloadJs = fs.readFileSync(preloadPath, "utf8");
        if (!preloadJs.includes("electronHotload")) {
            preloadJs += "\n\nelectron.contextBridge.exposeInMainWorld(\n\t'electronHotload', {\n\t\treloadWindow: () => {\n\t\t\telectron.ipcRenderer.send('reload-window');\n\t\t}\n\t}\n);\n";
            fs.writeFileSync(preloadPath, preloadJs);
        }
    }
}

function getAllShaders(dirPath) {
    let files = [];

    const items = fs.readdirSync(dirPath);

    items.forEach((item) => {
        const fullPath = path.join(dirPath, item);
        const stat = fs.statSync(fullPath);

        if (stat.isDirectory()) {
            files = files.concat(getAllShaders(fullPath));
        } else if (stat.isFile() && fullPath.endsWith(".glsl")) {
            files.push(fullPath);
        }
    });

    return files;
}

function shaderTargetUsesSpirv() {
    function argValue(name) {
        for (let i = 0; i < process.argv.length; i++) {
            const arg = process.argv[i];
            if (arg === name) {
                return process.argv[i + 1];
            }
            if (arg.startsWith(`${name}=`)) {
                return arg.substring(name.length + 1);
            }
        }
        return null;
    }

    const graphics = argValue("--graphics") ?? "default";
    if (graphics === "vulkan") {
        return true;
    }
    if (graphics !== "default" || typeof platform === "undefined" || typeof Platform === "undefined") {
        return false;
    }
    return platform === Platform.Android || platform === Platform.Linux;
}

function patchKhaVulkanDescriptorLayouts() {
    const makePath = process.argv[1];
    if (!makePath) {
        return;
    }

    const pipelinePath = path.join(
        path.dirname(makePath),
        "Kore",
        "Backends",
        "Graphics5",
        "Vulkan",
        "Sources",
        "kinc",
        "backend",
        "graphics5",
        "pipeline.c.h"
    );
    if (!fs.existsSync(pipelinePath)) {
        return;
    }

    let source = fs.readFileSync(pipelinePath, "utf8");
    const writeTexDescOld = `\t\tif (vulkanTextures[i] != NULL) {
\t\t\ttex_descs[i].sampler = vulkanSamplers[i];
\t\t\ttex_descs[i].imageView = vulkanTextures[i]->impl.texture.view;
\t\t\ttexture_count++;
\t\t}
\t\telse if (vulkanRenderTargets[i] != NULL) {
\t\t\ttex_descs[i].sampler = vulkanSamplers[i];
\t\t\tif (vulkanRenderTargets[i]->impl.stage_depth == i) {
\t\t\t\ttex_descs[i].imageView = vulkanRenderTargets[i]->impl.depthView;
\t\t\t\tvulkanRenderTargets[i]->impl.stage_depth = -1;
\t\t\t}
\t\t\telse {
\t\t\t\ttex_descs[i].imageView = vulkanRenderTargets[i]->impl.sourceView;
\t\t\t}
\t\t\ttexture_count++;
\t\t}
\t\ttex_descs[i].imageLayout = VK_IMAGE_LAYOUT_GENERAL;`;

    const writeTexDescNew = `\t\tif (vulkanTextures[i] != NULL) {
\t\t\ttex_descs[i].sampler = vulkanSamplers[i];
\t\t\ttex_descs[i].imageView = vulkanTextures[i]->impl.texture.view;
\t\t\t// sengine: descriptor image layouts match bound resources.
\t\t\ttex_descs[i].imageLayout = vulkanTextures[i]->impl.texture.imageLayout;
\t\t\ttexture_count++;
\t\t}
\t\telse if (vulkanRenderTargets[i] != NULL) {
\t\t\ttex_descs[i].sampler = vulkanSamplers[i];
\t\t\tif (vulkanRenderTargets[i]->impl.stage_depth == i) {
\t\t\t\ttex_descs[i].imageView = vulkanRenderTargets[i]->impl.depthView;
\t\t\t\tvulkanRenderTargets[i]->impl.stage_depth = -1;
\t\t\t}
\t\t\telse {
\t\t\t\ttex_descs[i].imageView = vulkanRenderTargets[i]->impl.sourceView;
\t\t\t}
\t\t\ttex_descs[i].imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
\t\t\ttexture_count++;
\t\t}`;

    const inlineTexDescOld = `\t\tif (vulkanTextures[i] != NULL) {
\t\t\tassert(vulkanSamplers[i] != VK_NULL_HANDLE);
\t\t\ttex_desc[i].sampler = vulkanSamplers[i];
\t\t\ttex_desc[i].imageView = vulkanTextures[i]->impl.texture.view;
\t\t\ttexture_count++;
\t\t}
\t\telse if (vulkanRenderTargets[i] != NULL) {
\t\t\ttex_desc[i].sampler = vulkanSamplers[i];
\t\t\tif (vulkanRenderTargets[i]->impl.stage_depth == i) {
\t\t\t\ttex_desc[i].imageView = vulkanRenderTargets[i]->impl.depthView;
\t\t\t\tvulkanRenderTargets[i]->impl.stage_depth = -1;
\t\t\t}
\t\t\telse {
\t\t\t\ttex_desc[i].imageView = vulkanRenderTargets[i]->impl.sourceView;
\t\t\t}
\t\t\ttexture_count++;
\t\t}
\t\ttex_desc[i].imageLayout = VK_IMAGE_LAYOUT_GENERAL;`;

    const inlineTexDescNew = `\t\tif (vulkanTextures[i] != NULL) {
\t\t\tassert(vulkanSamplers[i] != VK_NULL_HANDLE);
\t\t\ttex_desc[i].sampler = vulkanSamplers[i];
\t\t\ttex_desc[i].imageView = vulkanTextures[i]->impl.texture.view;
\t\t\t// sengine: descriptor image layouts match bound resources.
\t\t\ttex_desc[i].imageLayout = vulkanTextures[i]->impl.texture.imageLayout;
\t\t\ttexture_count++;
\t\t}
\t\telse if (vulkanRenderTargets[i] != NULL) {
\t\t\ttex_desc[i].sampler = vulkanSamplers[i];
\t\t\tif (vulkanRenderTargets[i]->impl.stage_depth == i) {
\t\t\t\ttex_desc[i].imageView = vulkanRenderTargets[i]->impl.depthView;
\t\t\t\tvulkanRenderTargets[i]->impl.stage_depth = -1;
\t\t\t}
\t\t\telse {
\t\t\t\ttex_desc[i].imageView = vulkanRenderTargets[i]->impl.sourceView;
\t\t\t}
\t\t\ttex_desc[i].imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
\t\t\ttexture_count++;
\t\t}`;

    const patched = source
        .replace(writeTexDescOld, writeTexDescNew)
        .replace(inlineTexDescOld, inlineTexDescNew);

    if (patched !== source) {
        fs.writeFileSync(pipelinePath, patched, "utf8");
    }

    const texturePath = path.join(
        path.dirname(makePath),
        "Kore",
        "Backends",
        "Graphics5",
        "Vulkan",
        "Sources",
        "kinc",
        "backend",
        "graphics5",
        "texture.c.h"
    );
    if (!fs.existsSync(texturePath)) {
        return;
    }

    source = fs.readFileSync(texturePath, "utf8");
    const textureLayoutOld = `\tif (usage & VK_IMAGE_USAGE_STORAGE_BIT) {
\t\ttex_obj->imageLayout = VK_IMAGE_LAYOUT_GENERAL;
\t}
\telse {
\t\ttex_obj->imageLayout = VK_IMAGE_LAYOUT_GENERAL; // VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
\t}`;
    const textureLayoutNew = `\tif (usage & VK_IMAGE_USAGE_STORAGE_BIT) {
\t\ttex_obj->imageLayout = VK_IMAGE_LAYOUT_GENERAL;
\t}
\telse {
\t\t// sengine: sampled textures are used through COMBINED_IMAGE_SAMPLER descriptors.
\t\ttex_obj->imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
\t}`;

    const patchedTexture = source.replace(textureLayoutOld, textureLayoutNew);
    if (patchedTexture !== source) {
        fs.writeFileSync(texturePath, patchedTexture, "utf8");
    }

    const vulkanPath = path.join(
        path.dirname(makePath),
        "Kore",
        "Backends",
        "Graphics5",
        "Vulkan",
        "Sources",
        "kinc",
        "backend",
        "graphics5",
        "Vulkan.c.h"
    );
    if (!fs.existsSync(vulkanPath)) {
        return;
    }

    source = fs.readFileSync(vulkanPath, "utf8");
    if (!source.includes("#include <stdio.h>")) {
        source = source.replace("#include <stdlib.h>", "#include <stdlib.h>\n#include <stdio.h>");
    }
    const debugCallbackOld = `\t\tkinc_log(KINC_LOG_LEVEL_ERROR, "Vulkan ERROR: Code %d : %s", pCallbackData->messageIdNumber, pCallbackData->pMessage);
\t\tkinc_debug_break();`;
    const debugCallbackNew = `\t\tkinc_log(KINC_LOG_LEVEL_ERROR, "Vulkan ERROR: Code %d : %s", pCallbackData->messageIdNumber, pCallbackData->pMessage);
\t\t// sengine: mirror validation errors to stderr so redirected smoke tests can capture them before the debug break.
\t\tfprintf(stderr, "Vulkan ERROR: Code %d : %s\\n", pCallbackData->messageIdNumber, pCallbackData->pMessage);
\t\tfflush(stderr);
\t\tkinc_debug_break();`;
    const patchedVulkan = source.includes("mirror validation errors to stderr")
        ? source
        : source.replace(debugCallbackOld, debugCallbackNew);
    if (patchedVulkan !== source) {
        fs.writeFileSync(vulkanPath, patchedVulkan, "utf8");
    }

    const vulkanUnitPath = path.join(
        path.dirname(makePath),
        "Kore",
        "Backends",
        "Graphics5",
        "Vulkan",
        "Sources",
        "kinc",
        "backend",
        "graphics5",
        "vulkanunit.c"
    );
    if (!fs.existsSync(vulkanUnitPath)) {
        return;
    }

    source = fs.readFileSync(vulkanUnitPath, "utf8");
    const semaphoreGlobalsOld = `static VkSemaphore framebuffer_available;
static VkSemaphore relay_semaphore;
static bool wait_for_relay = false;`;
    const semaphoreGlobalsNew = `static VkSemaphore framebuffer_available;
#define SENGINE_MAX_SWAPCHAIN_SEMAPHORES 16
static VkSemaphore relay_semaphores[SENGINE_MAX_SWAPCHAIN_SEMAPHORES];
static bool wait_for_relay = false;

static VkSemaphore *current_relay_semaphore(void) {
\tuint32_t image = vk_ctx.windows[vk_ctx.current_window].current_image;
\treturn &relay_semaphores[image % SENGINE_MAX_SWAPCHAIN_SEMAPHORES];
}`;
    const patchedUnit = source.replace(semaphoreGlobalsOld, semaphoreGlobalsNew);
    let patchedUnitWithPresentReset = patchedUnit;
    if (!patchedUnitWithPresentReset.includes("static void command_list_did_present(void);")) {
        patchedUnitWithPresentReset = patchedUnitWithPresentReset.replace(
            "static void command_list_should_wait_for_framebuffer(void);",
            "static void command_list_should_wait_for_framebuffer(void);\nstatic void command_list_did_present(void);"
        );
    }
    if (patchedUnitWithPresentReset !== source) {
        fs.writeFileSync(vulkanUnitPath, patchedUnitWithPresentReset, "utf8");
    }

    source = fs.readFileSync(vulkanPath, "utf8");
    const semaphoreCreateOld = `\terr = vkCreateSemaphore(vk_ctx.device, &semInfo, NULL, &relay_semaphore);
\tassert(!err);`;
    const semaphoreCreateNew = `\tfor (int i = 0; i < SENGINE_MAX_SWAPCHAIN_SEMAPHORES; ++i) {
\t\terr = vkCreateSemaphore(vk_ctx.device, &semInfo, NULL, &relay_semaphores[i]);
\t\tassert(!err);
\t}`;
    const presentSemaphoreOld = `\tpresent.pWaitSemaphores = &relay_semaphore;
\tpresent.waitSemaphoreCount = 1;`;
    const presentSemaphoreNew = `\tpresent.pWaitSemaphores = NULL;
\tpresent.waitSemaphoreCount = 0;`;
    const presentSemaphoreIntermediateOld = `\tVkSemaphore *relay = current_relay_semaphore();
\tpresent.pWaitSemaphores = relay;
\tpresent.waitSemaphoreCount = 1;`;
    const presentSemaphoreConditionalOld = `\tVkSemaphore *relay = current_relay_semaphore();
\tpresent.pWaitSemaphores = wait_for_relay ? relay : NULL;
\tpresent.waitSemaphoreCount = wait_for_relay ? 1 : 0;`;
    const presentRelayResetOld = `\twait_for_relay = false;`;
    const presentRelayResetNew = `\tcommand_list_did_present();`;
    const patchedVulkanSemaphores = source
        .replace(semaphoreCreateOld, semaphoreCreateNew)
        .replace(presentSemaphoreOld, presentSemaphoreNew)
        .replace(presentSemaphoreIntermediateOld, presentSemaphoreNew)
        .replace(presentSemaphoreConditionalOld, presentSemaphoreNew)
        .replace(presentRelayResetOld, presentRelayResetNew);
    if (patchedVulkanSemaphores !== source) {
        fs.writeFileSync(vulkanPath, patchedVulkanSemaphores, "utf8");
    }

    const commandListPath = path.join(
        path.dirname(makePath),
        "Kore",
        "Backends",
        "Graphics5",
        "Vulkan",
        "Sources",
        "kinc",
        "backend",
        "graphics5",
        "commandlist.c.h"
    );
    if (!fs.existsSync(commandListPath)) {
        return;
    }

    source = fs.readFileSync(commandListPath, "utf8");
    const commandListSemaphoreOld = `\tVkSemaphore semaphores[2] = {framebuffer_available, relay_semaphore};`;
    const commandListSemaphoreNew = `\tVkSemaphore *relay = current_relay_semaphore();
\tVkSemaphore semaphores[2] = {framebuffer_available, *relay};`;
    const commandListSignalOld = `\tsubmit_info.pSignalSemaphores = &relay_semaphore;`;
    const commandListSignalNew = `\tsubmit_info.pSignalSemaphores = relay;`;
    const commandListRelayStateOld = `\tVkSemaphore *relay = current_relay_semaphore();
\tVkSemaphore semaphores[2] = {framebuffer_available, *relay};`;
    const commandListRelayStateNew = `\tVkSemaphore *relay = current_relay_semaphore();
\tVkSemaphore semaphores[2] = {framebuffer_available, *relay};
\tbool signal_relay = wait_for_framebuffer || wait_for_relay;`;
    const commandListSignalBlockOld = `\tsubmit_info.signalSemaphoreCount = 1;
\tsubmit_info.pSignalSemaphores = relay;
\twait_for_relay = true;`;
    const commandListSignalBlockNew = `\t// sengine: keep Vulkan validation happy by waiting on the submit fence instead of passing a present semaphore around.
\tsubmit_info.signalSemaphoreCount = 0;
\tsubmit_info.pSignalSemaphores = NULL;
\twait_for_relay = false;`;
    const commandListSignalBlockIntermediateOld = `\tif (signal_relay) {
\t\tsubmit_info.signalSemaphoreCount = 1;
\t\tsubmit_info.pSignalSemaphores = relay;
\t\twait_for_relay = true;
\t}
\telse {
\t\tsubmit_info.signalSemaphoreCount = 0;
\t\tsubmit_info.pSignalSemaphores = NULL;
\t}`;
    const commandListSubmitOld = `\terr = vkQueueSubmit(vk_ctx.queue, 1, &submit_info, list->impl.fence);
\tassert(!err);`;
    const commandListSubmitNew = `\terr = vkQueueSubmit(vk_ctx.queue, 1, &submit_info, list->impl.fence);
\tassert(!err);

\t// sengine: synchronous submit avoids reusing semaphores still owned by the swapchain presentation engine.
\terr = vkWaitForFences(vk_ctx.device, 1, &list->impl.fence, VK_TRUE, UINT64_MAX);
\tassert(!err);`;
    const commandListPresentResetAnchor = `static void command_list_should_wait_for_framebuffer(void) {
\twait_for_framebuffer = true;
}`;
    const commandListPresentResetBlock = `static void command_list_should_wait_for_framebuffer(void) {
\twait_for_framebuffer = true;
}

static void command_list_did_present(void) {
\twait_for_framebuffer = false;
\twait_for_relay = false;
}`;
    let patchedCommandList = source
        .replace(commandListSemaphoreOld, commandListSemaphoreNew)
        .replace(commandListSignalOld, commandListSignalNew);
    if (!patchedCommandList.includes("bool signal_relay = wait_for_framebuffer || wait_for_relay;")) {
        patchedCommandList = patchedCommandList.replace(commandListRelayStateOld, commandListRelayStateNew);
    }
    patchedCommandList = patchedCommandList
        .replace(commandListSignalBlockOld, commandListSignalBlockNew)
        .replace(commandListSignalBlockIntermediateOld, commandListSignalBlockNew);
    if (!patchedCommandList.includes("synchronous submit avoids reusing semaphores")) {
        patchedCommandList = patchedCommandList.replace(commandListSubmitOld, commandListSubmitNew);
    }
    if (!patchedCommandList.includes("static void command_list_did_present(void) {")) {
        patchedCommandList = patchedCommandList.replace(commandListPresentResetAnchor, commandListPresentResetBlock);
    }
    if (patchedCommandList !== source) {
        fs.writeFileSync(commandListPath, patchedCommandList, "utf8");
    }
}

function assembleShaders(shaderDir, outputDir, stripExplicitLocations) {
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    } else {
        clearDirectory(outputDir);
    }
    copyDirectories(shaderDir, outputDir);

    const shaderFiles = getAllShaders(shaderDir);
    let shaderFilesRelative = [];
    for (const shaderFile of shaderFiles)
        shaderFilesRelative.push(path.relative(shaderDir, shaderFile));

    shaderFilesRelative.forEach((shaderFile) => {
        function assemble(shaderFile) {
            if (verbose) {
                console.log(`Processing shader: ${shaderFile}`);
            }

            const shaderPath = path.join(shaderDir, shaderFile);
            const outputPath = path.join(outputDir, shaderFile);

            if (!fs.existsSync(outputPath)) {
                const includeRegex = /^\s*#include\s+"(.+)"\s*$/gm;
                let shaderSource = fs.readFileSync(shaderPath, "utf8");
                let match;
                while ((match = includeRegex.exec(shaderSource)) !== null) {
                    const includePath = `${path.resolve(
                        outputDir,
                        match[1]
                    )}.glsl`;
                    if (!fs.existsSync(includePath)) {
                        try {
                            assemble(`${match[1]}.glsl`);
                        } catch (e) {
                            console.log(
                                `Failed to include: ${includePath}: ${e}`
                            );
                            return;
                        }
                    }

                    const includeContent = fs.readFileSync(includePath, "utf8");
                    shaderSource = shaderSource.replace(
                        match[0],
                        includeContent
                    );
                }

                if (stripExplicitLocations) {
                    // Kha's SPIR-V pipeline assigns interface locations on its own.
                    // Keeping explicit GLSL location qualifiers here produces duplicate
                    // SPIR-V OpDecorate Location entries and fails spirv-val.
                    shaderSource = shaderSource.replace(
                        /layout\s*\(\s*location\s*=\s*\d+\s*\)\s+/g,
                        ""
                    );
                }

                fs.writeFileSync(outputPath, shaderSource, "utf8");
            }
        }

        assemble(shaderFile);
    });
}

const shaderInputDir = path.join(__dirname, "shaders");
const shaderOutputDir = path.join(process.cwd(), "build", "shaders_assembled");
const shaderUsesSpirv = shaderTargetUsesSpirv();
if (shaderUsesSpirv) {
    patchKhaVulkanDescriptorLayouts();
}
assembleShaders(shaderInputDir, shaderOutputDir, shaderUsesSpirv);

let project = new Project("s");
project.addSources("src");
project.addAssets("assets/**", {
    nameBaseDir: "assets",
    destination: "assets/{dir}/{name}",
    name: "{name}",
});

// asset types
process.assetTypes = process.assetTypes ?? {}
process.assetTypes["Font"] = {
    type: "s.assets.internal.font.Font", 
    resource: "Font",
    formats:{
        "ttf": "s.assets.internal.font.format.TTF"
    }
};
process.assetTypes["Image"] = {
    type: "s.assets.internal.image.Image", 
    resource: "Image",
    formats:{
        "bmp": "s.assets.internal.image.format.BMP",
        "exr": "s.assets.internal.image.format.EXR",
        "hdr": "s.assets.internal.image.format.HDR",
        "jpg": "s.assets.internal.image.format.JPG",
        "png": "s.assets.internal.image.format.PNG",
        "psd": "s.assets.internal.image.format.PSD",
        "tga": "s.assets.internal.image.format.TGA",
        "tif": "s.assets.internal.image.format.TIF"
    }
};
process.assetTypes["AnimatedImage"] = {
    type: "s.assets.internal.image.AnimatedImage", 
    resource: "Image",
    formats:{
        "gif": "s.assets.internal.image.format.GIF"
    }
};

for (const [k, v] of Object.entries(process.assetTypes)) {
    var formats = [];
    for ([e, t] of Object.entries(v.formats))
        formats.push({extension: e, type: t});
    project.addParameter(`--macro s.macro.AssetsMacro.addAssetType("${k}", "${v.resource}", "${v.type}", ${JSON.stringify(formats)})`);
}

// markup shortcuts
for (const [k, v] of Object.entries(process.shortcuts ?? {})) {
    if (typeof k !== "string" || typeof v !== "string" || !v) continue;
    project.addParameter(
        `--macro s.ui.macro.ElementMacro.useShortcut(${JSON.stringify(k)}, ${JSON.stringify(v)})`
    );
}

// defines
let defs = [];
for (const def of (process.defines ?? [])) {
    let kv = def.split(" ");
    if (kv.length === 2) {
        project.addDefine(`${kv[0]}=${kv[1]}`);
        defs.push(`${kv[0]} ${kv[1]}`);
    } else {
        project.addDefine(def);
        defs.push(`${kv[0]} 1`);
    }
}
if (shaderUsesSpirv) {
    defs.push("S_SPIRV 1");
}

// shaders
project.addShaders(`${shaderOutputDir}/**/*{frag,vert}.glsl`, { defines: defs });

// libraries
project.localLibraryPath = "libs";
project.addLibrary("slog");
project.addLibrary("snet");
project.addLibrary("sshortcut");
project.addLibrary("sextensions");

const hotloadEnabled = process.argv.includes("--watch") || process.argv.includes("--hotload");

// hotload
if (hotloadEnabled) { 
    project.addDefine('hotload');
    // allow eval in electron
	project.targetOptions.html5.unsafeEval = true;
    // to support constructors patching, optional
	project.addDefine('js_classic'); 
    // client code for code-patching
    const buildDir = path.join(path.resolve('.'), 'build', platform);
    callbacks.postBuild = () => {
        ensureUnsafeEvalHtml5(buildDir);
        ensureElectronReloadBridge(buildDir);
    };
    callbacks.postHaxeCompilation = () => {
        ensureUnsafeEvalHtml5(buildDir);
        ensureElectronReloadBridge(buildDir);
    };
    if (process.argv.includes("--watch")) {
    	// start websocket server that will send type diffs to client
    	const { Server } = require("./server.js");
    	// path to target build folder and main js file.
    	const server = new Server(`${path.resolve('.')}/build/${platform}`, 'kha.js');
        callbacks.onFailure = (error) => {
            const message = error && error.stack ? error.stack : String(error);
            server.reportError(message);
        };
        // parse js file every compilation
     	callbacks.postHaxeRecompilation = () => {
            ensureUnsafeEvalHtml5(buildDir);
            ensureElectronReloadBridge(buildDir);
            server.reload();
        };
    	// for assets reloading
    	callbacks.postAssetReexporting = (path) => server.reloadAsset(path);
    }
}

// subprojects
await project.addProject("libs/aura");

resolve(project);
