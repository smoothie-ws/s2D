package s.stage2d.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_DEFERRED == 1)
import kha.Shaders;
import kha.graphics4.VertexStructure;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.stage2d.Stage;

@:access(s.stage2d.Stage)
@:allow(s.ui.graphics.StageRenderer)
@:dox(hide)
class GeometryPass extends StageRenderPass {
	var viewProjectionCL:ConstantLocation;
	var albedoMapTU:TextureUnit;
	var normalMapTU:TextureUnit;
	var emissionMapTU:TextureUnit;
	#if (S2D_LIGHTING_PBR == 1)
	var ormMapTU:TextureUnit;
	#end
	#if (S2D_SPRITE_INSTANCING != 1)
	var depthCL:ConstantLocation;
	var modelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end

	public function new(inputLayout:Array<VertexStructure>) {
		super({
			inputLayout: inputLayout,
			vertexShader: Reflect.field(Shaders, "sprite_vert"),
			fragmentShader: Reflect.field(Shaders, "geometry_frag"),
			depthWrite: true,
			depthMode: Less,
			depthStencilAttachment: DepthOnly
		});
	}

	function setup() {
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		#if (S2D_LIGHTING_PBR == 1)
		ormMapTU = pipeline.getTextureUnit("ormMap");
		#end
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
	}

	function render(stage:Stage) @:privateAccess {
		if (!compiled)
			compile();
		final ctx = stage.renderBuffer.depthMap.context3D;
		ctx.begin([
			stage.renderBuffer.albedoMap,
			stage.renderBuffer.normalMap,
			stage.renderBuffer.emissionMap,
			#if (S2D_LIGHTING_PBR == 1)
			stage.renderBuffer.ormMap
			#end
		]);
		ctx.clear(Black, 1.0);
		ctx.setPipeline(pipeline);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setMesh(Shader.quad);
		#end
		ctx.setMat3(viewProjectionCL, stage.viewProjection);
		for (layer in stage.layers) {
			#if (S2D_LIGHTING_SHADOWS == 1)
			@:privateAccess layer.shadowBuffer.updateBuffersData();
			#end
			#if (S2D_SPRITE_INSTANCING == 1)
			for (material in layer.materials) {
				ctx.setVertexBuffers(material.vertices);
				ctx.setTexture(albedoMapTU, material.albedoMap);
				ctx.setTexture(normalMapTU, material.normalMap);
				ctx.setTexture(emissionMapTU, material.emissionMap);
				#if (S2D_LIGHTING_PBR == 1)
				ctx.setTexture(ormMapTU, material.ormMap);
				#end
				ctx.drawInstanced(material.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				ctx.setFloat(depthCL, sprite.z);
				ctx.setMat3(modelCL, sprite.transform);
				ctx.setVec4(cropRectCL, sprite.cropRect);
				ctx.setTexture(albedoMapTU, sprite.material.albedoMap);
				ctx.setTexture(normalMapTU, sprite.material.normalMap);
				ctx.setTexture(emissionMapTU, sprite.material.emissionMap);
				#if (S2D_LIGHTING_PBR == 1)
				ctx.setTexture(ormMapTU, sprite.material.ormMap);
				#end
				ctx.draw();
			}
			#end
		}
		ctx.end();
	}
}
#end
