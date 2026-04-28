package s.ui.graphics;

import s.graphics.ConstantLocation;
import s.ui.elements.ImageElement;

class ImageDrawer<T:ImageElement = ImageElement> extends TexturedDrawer<T> {
	var clipRectCL:ConstantLocation;

	override function setup() {
		super.setup();
		clipRectCL = pipeline.getConstantLocation("clipRect");
	}

	override function setUniforms(target:s.graphics.RenderTarget, element:T) {
		super.setUniforms(target, element);
		final ctx = target.context3D;
		ctx.setVec4(rectCL, element.rect);
		ctx.setVec4(clipRectCL, element.clipRect);
	}
}
