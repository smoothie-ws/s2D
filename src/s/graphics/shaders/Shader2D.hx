package s.graphics.shaders;

import s.graphics.ConstantLocation;

abstract class Shader2D extends Shader {
	var mvpCL:ConstantLocation;
	var colorCL:ConstantLocation;

	function new(frag:String = "shader2d", vert:String = "shader2d") {
		super({
			inputLayout: [Shader.structure2D],
			vertexShader: vert,
			fragmentShader: frag,
			alphaBlendSource: BlendOne,
			alphaBlendDestination: InverseSourceAlpha,
			blendSource: SourceAlpha,
			blendDestination: InverseSourceAlpha
		});
	}

	override function setup() {
		mvpCL = pipeline.getConstantLocation("mvp");
		colorCL = pipeline.getConstantLocation("color");
	}

	function set(context:Context2D) {
		var style = context.style;
		var color = style.color;
		var ctx = context.context;
		ctx.setPipeline(pipeline);
		ctx.setMat3(mvpCL, context.transform);
		ctx.setVec4(colorCL, color.r, color.g, color.b, color.a * style.opacity);
	}

	function setRect(ctx:Context3D, x:Float, y:Float, rw:Float, rh:Float, u:Float, v:Float, cw:Float, ch:Float) {
		ctx.addPolygon([
			[x, y + rh, u, v + ch],
			[x, y, u, v],
			[x + rw, y, u + cw, v],
			[x + rw, y + rh, u + cw, v + ch]
		]);
	}
}
