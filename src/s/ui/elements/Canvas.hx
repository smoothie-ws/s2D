package s.ui.elements;

import kha.Image;
import s.Color;
import s.math.Mat3;
import s.geometry.ISize;
import s.graphics.Context2D;
import s.graphics.RenderTarget;
import s.graphics.TextureParameters;
import s.graphics.DepthStencilFormat;

class Canvas extends Textured<RenderTarget> {
	@:attr(textureParameters) var size:ISize;

	@:attr public var textureSize:ISize;
	@:attr(textureParameters) public var format:TextureFormat = TextureFormat.RGBA32;
	@:attr(textureParameters) public var samples:Int = 1;
	@:attr(textureParameters) public var depthStencil:DepthStencilFormat = NoDepthAndStencil;

	public function paint(clear:Bool = true, color:Color = Transparent, f:Context2D->Void):Void
		texture?.context2D.draw(clear, color, f);

	override function update() {
		super.update();

		if (textureSizeDirty || textureSize == null && (widthDirty || heightDirty))
			size = textureSize ?? new ISize(width, height);

		if (!textureParametersDirty)
			return;

		var tex = texture;
		
		final texWidth = size.width > 0 ? size.width : 1;
		final texHeight = size.height > 0 ? size.height : 1;
		final drawWidth = width > 0 ? width : 1;
		final drawHeight = height > 0 ? height : 1;

		texture = new RenderTarget(texWidth, texHeight, format, depthStencil, samples);
		if (Image.renderTargetsInvertedY())
			texture.context2D.transform.setFrom(Mat3.orthogonalProjection(0, drawWidth, 0, drawHeight));
		else
			texture.context2D.transform.setFrom(Mat3.orthogonalProjection(0, drawWidth, drawHeight, 0));

		if (tex == null)
			return;

		if (width > 0 && height > 0)
			paint(ctx -> {
				ctx.style.color = White;
				ctx.drawScaledImage(tex, 0.0, 0.0, width, height);
			});

		tex.unload();
	}
}
