package s.stage2d.graphics.lighting;

#if (S2D_LIGHTING)
import kha.Shaders;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.VertexStructure;
import s.stage2d.Stage;

@:access(s.stage2d.Stage)
@:allow(s.ui.graphics.StageRenderer)
@:dox(hide)
class LightingPass extends StageRenderPass {
	var viewProjectionCL:ConstantLocation;
	var lightsCL:ConstantLocation;
	var albedoMapTU:TextureUnit;
	var normalMapTU:TextureUnit;
	var emissionMapTU:TextureUnit;
	#if (S2D_LIGHTING_PBR == 1)
	var ormMapTU:TextureUnit;
	#end
	#if (S2D_LIGHTING_ENVIRONMENT == 1)
	var envPipeline:PipelineState;
	var envMapTU:TextureUnit;
	#end
	#if (S2D_LIGHTING_DEFERRED != 1 && S2D_SPRITE_INSTANCING != 1)
	var depthCL:ConstantLocation;
	var modelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end

	public function new(inputLayout:Array<VertexStructure>) {
		super({
			#if (S2D_LIGHTING_DEFERRED == 1)
			inputLayout: [inputLayout[0]], vertexShader: Reflect.field(Shaders, "s2d_2d_vert"), fragmentShader: Reflect.field(Shaders, "lighting_deferred_frag")
			#else
			inputLayout: inputLayout, vertexShader: Reflect.field(Shaders, "sprite_vert"), fragmentShader: Reflect.field(Shaders, "lighting_forward_frag"),
			alphaBlendSource: One, alphaBlendDestination: InverseSourceAlpha, blendSource: SourceAlpha, blendDestination: InverseSourceAlpha
			#end
		});
	}

	function setup() {
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		lightsCL = pipeline.getConstantLocation("lights");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		#if (S2D_LIGHTING_PBR == 1)
		ormMapTU = pipeline.getTextureUnit("ormMap");
		#end
		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		envPipeline = new PipelineState();
		envMapTU = envPipeline.getTextureUnit("envMap");
		#end
		#if (S2D_LIGHTING_DEFERRED != 1 && S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
	}

	function render(stage:Stage) @:privateAccess {
		if (!compiled)
			compile();
		final buffer = stage.renderBuffer;
		final ctx = buffer.tgt.context3D;

		ctx.begin();
		ctx.clear(stage.color);
		ctx.setPipeline(pipeline);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setMesh(Shader.quad);
		#end
		ctx.setMat3(viewProjectionCL, stage.viewProjection);
		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		ctx.setPipeline(envPipeline);
		ctx.setTexture(envMapTU, stage.environmentMap);
		ctx.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		#if (S2D_LIGHTING_DEFERRED == 1)
		ctx.setTexture(albedoMapTU, buffer.albedoMap);
		ctx.setTexture(normalMapTU, buffer.normalMap);
		ctx.setTexture(emissionMapTU, buffer.emissionMap);
		#if (S2D_LIGHTING_PBR == 1)
		ctx.setTexture(ormMapTU, buffer.ormMap);
		#end
		for (layer in stage.layers) {
			for (light in layer.lights) {
				#if (S2D_LIGHTING_SHADOWS == 1)
				ctx.end();
				ShadowPass.render(light);
				ctx.begin();
				ctx.setPipeline(pipeline);
				ctx.setMesh(Shader.quad);
				ctx.setTexture(shadowMapTU, buffer.shadowMap);
				#end
				ctx.setFloat3(lightPositionCL, light.x, light.y, light.z);
				ctx.setVec3(lightColorCL, light.color.RGB);
				ctx.setFloat2(lightAttribCL, light.power, light.radius);
				ctx.draw();
			}
		}
		#else
		for (layer in stage.layers) {
			ctx.setFloats(lightsCL, layer.getLightsBuffer());
			#if (S2D_SPRITE_INSTANCING == 1)
			for (material in layer.materials) {
				ctx.setVertexBuffers(material.vertices);
				ctx.setTexture(albedoMapTU, material.albedoMap, {});
				ctx.setTexture(normalMapTU, material.normalMap, {});
				ctx.setTexture(emissionMapTU, material.emissionMap, {});
				#if (S2D_LIGHTING_PBR == 1)
				ctx.setTexture(ormMapTU, material.ormMap, {});
				#end
				ctx.drawInstanced(material.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				ctx.setFloat(depthCL, sprite.z);
				ctx.setMat3(modelCL, sprite.transform);
				ctx.setVec4(cropRectCL, sprite.cropRect);
				ctx.setTexture(albedoMapTU, sprite.material.albedoMap, {});
				ctx.setTexture(normalMapTU, sprite.material.normalMap, {});
				ctx.setTexture(emissionMapTU, sprite.material.emissionMap, {});
				#if (S2D_LIGHTING_PBR == 1)
				ctx.setTexture(ormMapTU, sprite.material.ormMap, {});
				#end
				ctx.draw();
			}
			#end
		}
		#end
		ctx.end();
	}
}
#end
