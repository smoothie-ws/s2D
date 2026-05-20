package s.ui.graphics;

import s.graphics.ConstantLocation;
import s.graphics.TextureUnit;
import s.ui.elements.Textured;

@:allow(s.ui.elements.Drawable)
@:access(s.ui.elements.Drawable)
class TexturedDrawer<T:Textured = Textured> extends ElementDrawer<T> {
	var sourceTU:TextureUnit;
	var clipRectCL:ConstantLocation;

	function new(?frag:String, ?vert:String)
		super(frag ?? "texture", vert ?? "texture");

	override function setup() {
		super.setup();
		sourceTU = pipeline.getTextureUnit("source");
		clipRectCL = pipeline.getConstantLocation("clipRect");
	}

	override function setUniforms(target:s.graphics.RenderTarget, element:T) {
		super.setUniforms(target, element);
		target.context3D.setVec4(clipRectCL, 0.0, 0.0, 1.0, 1.0);
		target.context3D.setTexture(sourceTU, element.texture, element.parameters);
	}
}
