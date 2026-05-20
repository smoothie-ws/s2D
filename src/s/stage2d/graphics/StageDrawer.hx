package s.stage2d.graphics;

import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.shaders.Shader;

@:allow(s.stage2d.Stage)
class StageDrawer extends Shader {
	var mvpCL:ConstantLocation;
	var depthCL:ConstantLocation;
	var sourceClipRectCL:ConstantLocation;
	var sourceTU:TextureUnit;

	public function new()
		super({
			inputLayout: [Shader.structure2D],
			vertexShader: "sprite",
			fragmentShader: "sprite",
			blendSource: BlendOne,
			blendDestination: InverseSourceAlpha,
			alphaBlendSource: BlendOne,
			alphaBlendDestination: InverseSourceAlpha
		});

	override function setup() {
		mvpCL = pipeline.getConstantLocation("mvp");
		depthCL = pipeline.getConstantLocation("depth");
		sourceClipRectCL = pipeline.getConstantLocation("sourceClipRect");
		sourceTU = pipeline.getTextureUnit("source");
	}

	function render(stage:Stage) @:privateAccess {
		if (!compiled)
			compile();

		final ctx = stage.texture.context3D;
		ctx.begin();
		ctx.clear(stage.color);
		var drawing = false;

		for (sprite in stage.sprites) {
			if (!sprite.source?.isLoaded)
				continue;
			if (!drawing) {
				ctx.setPipeline(pipeline);
				ctx.setMesh(Shader.quad);
				drawing = true;
			}
			ctx.setMat3(mvpCL, sprite.transform * stage.viewProjection);
			ctx.setFloat(depthCL, sprite.z);
			ctx.setVec4(sourceClipRectCL, sprite.sourceClipRect);
			ctx.setTexture(sourceTU, sprite.source);
			ctx.draw();
		}

		ctx.end();
	}
}
