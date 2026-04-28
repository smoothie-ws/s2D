const fs = require("fs");
const path = require("path");
const cp = require("child_process");

function exists(filePath) {
	return fs.existsSync(filePath);
}

function fail(message) {
	console.error(`[docs] ${message}`);
	process.exit(1);
}

function findKhaMakeJs() {
	const khaPath = process.env.KHA_PATH;
	if (khaPath) {
		const base = path.resolve(khaPath);
		const candidates = [path.join(base, "make.js"), path.join(base, "Kha", "make.js")];
		for (const candidate of candidates) {
			if (exists(candidate)) return candidate;
		}
		fail(`KHA_PATH is set to "${khaPath}", but make.js was not found.`);
	}

	const localRepoKha = path.resolve(__dirname, "..", "Kha", "make.js");
	if (exists(localRepoKha)) return localRepoKha;

	const homes = [];
	if (process.env.USERPROFILE) homes.push(process.env.USERPROFILE);
	if (process.env.HOME && !homes.includes(process.env.HOME)) homes.push(process.env.HOME);

	const extensionRoots = [];
	for (const home of homes) {
		extensionRoots.push(path.join(home, ".vscode", "extensions"));
		extensionRoots.push(path.join(home, ".vscode-insiders", "extensions"));
		extensionRoots.push(path.join(home, ".vscodium", "extensions"));
	}

	const found = [];
	for (const root of extensionRoots) {
		if (!exists(root)) continue;
		for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
			if (!entry.isDirectory()) continue;
			const makeJs = path.join(root, entry.name, "Kha", "make.js");
			if (!exists(makeJs)) continue;
			const stat = fs.statSync(makeJs);
			found.push({ makeJs, mtimeMs: stat.mtimeMs });
		}
	}

	found.sort((a, b) => b.mtimeMs - a.mtimeMs);
	if (found.length > 0) return found[0].makeJs;

	fail("Unable to locate Kha. Set KHA_PATH to your Kha directory.");
}

function runNodeScript(scriptPath, args, cwd) {
	const result = cp.spawnSync(process.execPath, [scriptPath, ...args], {
		cwd,
		stdio: "inherit",
	});
	if (result.error) fail(result.error.message);
	if (result.status !== 0) process.exit(result.status ?? 1);
}

const sengineRoot = path.resolve(__dirname, "..");
const makeJs = findKhaMakeJs();

console.log(`[docs] Using Kha: ${path.dirname(makeJs)}`);
runNodeScript(
	makeJs,
	[
		"--from",
		sengineRoot,
		"--target",
		"html5",
		"--main",
		"DocMain",
		"--nohaxe",
		"--silent",
	],
	sengineRoot
);

const generatedHxml = path.join(sengineRoot, "build", "project-html5.hxml");
if (!exists(generatedHxml)) {
	fail(`Expected generated file was not found: ${generatedHxml}`);
}

console.log(`[docs] Generated: ${generatedHxml}`);
