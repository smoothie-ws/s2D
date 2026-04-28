package s.stage2d.graphics;

import s.graphics.shaders.Shader;
#if (S2D_LIGHTING != 1)
import kha.Shaders;
import kha.graphics4.VertexStructure;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.stage2d.Stage;

@:dox(hide)
@:access(s.stage2d.Stage)
@:allow(s.ui.graphics.StageRenderer)
class SpritePass extends StageRenderPass {
	var viewProjectionCL:ConstantLocation;
	var textureMapTU:TextureUnit;
	#if (S2D_SPRITE_INSTANCING != 1)
	var depthCL:ConstantLocation;
	var modelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end

	public function new() {
		super({
			// inputLayout: inputLayout,
			vertexShader: Reflect.field(Shaders, "sprite_vert"),
			fragmentShader: Reflect.field(Shaders, "sprite_frag"),
			alphaBlendSource: One,
			alphaBlendDestination: InverseSourceAlpha,
			blendSource: SourceAlpha,
			blendDestination: InverseSourceAlpha
		});
	}

	override function setup() {
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		textureMapTU = pipeline.getTextureUnit("textureMap");
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
	}

	function render(stage:Stage) @:privateAccess {
		if (!compiled)
			compile();
		final ctx = stage.renderBuffer.tgt.context3D;
		ctx.begin();
		ctx.clear(stage.color);
		ctx.setPipeline(pipeline);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setMesh(Shader.quad);
		#end
		ctx.setMat3(viewProjectionCL, stage.viewProjection);
		for (layer in stage.layers) {
			#if (S2D_SPRITE_INSTANCING == 1)
			for (material in layer.materials) {
				ctx.setVertexBuffers(material.vertices);
				ctx.setTexture(textureMapTU, material.textureMap);
				ctx.drawInstanced(material.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				ctx.setFloat(depthCL, sprite.z);
				ctx.setMat3(modelCL, sprite.transform);
				ctx.setVec4(cropRectCL, sprite.cropRect);
				ctx.setTexture(textureMapTU, sprite.material.textureMap);
				ctx.draw();
			}
			#end
		}
		ctx.end();
	}
}
#end
