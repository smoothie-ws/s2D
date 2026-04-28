package s.ui.graphics.gradients;

import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.RenderTarget;
import s.graphics.TextureParameters;
import s.ui.gradients.Gradient;

@:allow(s.ui.gradients.Gradient)
abstract class GradientDrawer<T:Gradient> extends ElementDrawer<T> {
	var startCL:ConstantLocation;
	var endCL:ConstantLocation;
	var ditherCL:ConstantLocation;
	var gradientTU:TextureUnit;

	function new(fragmentShader:String) {
		super(fragmentShader);
	}

	override function setup() {
		super.setup();
		startCL = pipeline.getConstantLocation("start");
		endCL = pipeline.getConstantLocation("end");
		ditherCL = pipeline.getConstantLocation("dither");
		gradientTU = pipeline.getTextureUnit("gradient");
	}

	override function setUniforms(target:RenderTarget, element:T) {
		super.setUniforms(target, element);
		final l = element.left.position;
		final t = element.top.position;
		final w = element.width;
		final h = element.height;
		final start = element.start;
		final end = element.end;
		final ctx = target.context3D;
		ctx.setVec2(startCL, {x: l + start.x * w, y: t + start.y * h});
		ctx.setVec2(endCL, {x: l + end.x * w, y: t + end.y * h});
		ctx.setFloat(ditherCL, element.dither ? 0.05 : 0.0);
		ctx.setTexture(gradientTU, element.texture);
	}
}
