package s.graphics.shaders;

import s.assets.Image;
import s.graphics.TextureParameters;

class ImageShader extends TexturedShader {
	public function render(context:Context2D, img:Image, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float) {
		if (img == null || img.width <= 0 || img.height <= 0)
			return;

		super.set(context);
		final ctx = context.context;
		final invWidth = 1.0 / img.width;
		final invHeight = 1.0 / img.height;

		ctx.setTexture(sourceTU, img, Clamp, Clamp, LinearFilter, LinearFilter, NoMipFilter);
		setRect(ctx, dx, dy, dw, dh, sx * invWidth, sy * invHeight, sw * invWidth, sh * invHeight);
		ctx.flush();
	}
}
