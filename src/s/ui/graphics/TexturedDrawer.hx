package s.ui.graphics;

import s.graphics.TextureUnit;
import s.ui.elements.Textured;

@:allow(s.ui.elements.Drawable)
@:access(s.ui.elements.Drawable)
class TexturedDrawer<T:Textured = Textured> extends ElementDrawer<T> {
	var sourceTU:TextureUnit;

	function new(?frag:String, ?vert:String)
		super(frag ?? "texture", vert ?? "texture");

	override function setup() {
		super.setup();
		sourceTU = pipeline.getTextureUnit("source");
	}

	override function setUniforms(target:s.graphics.RenderTarget, element:T) {
		super.setUniforms(target, element);
		target.context3D.setTexture(sourceTU, element.texture, element.parameters);
	}
}
