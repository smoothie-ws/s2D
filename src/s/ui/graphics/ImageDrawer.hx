package s.ui.graphics;

import s.ui.elements.ImageElement;

class ImageDrawer<T:ImageElement = ImageElement> extends TexturedDrawer<T> {
	function new()
		super("texture", "image");

	override function setUniforms(target:s.graphics.RenderTarget, element:T) {
		super.setUniforms(target, element);
		final ctx = target.context3D;
		ctx.setVec4(rectCL, element.rect);
		ctx.setVec4(clipRectCL, element.clipRect);
	}
}
