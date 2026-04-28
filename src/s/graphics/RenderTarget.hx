package s.graphics;

import s.assets.Image;
import s.graphics.Context1D;
import s.graphics.Context2D;
import s.graphics.Context3D;
import s.graphics.TextureParameters;

/**
 * Render-target texture wrapper with access to 1D, 2D, and 3D graphics contexts.
 *
 * `RenderTarget` is a lightweight abstraction over `kha.Image` for render targets.
 * It is commonly used as an intermediate buffer, post-processing target, or
 * off-screen drawing surface.
 *
 * Typical usage:
 * ```haxe
 * var target = new RenderTarget(512, 512);
 * target.context2D.begin();
 * // draw into the texture
 * target.context2D.end();
 * ```
 */
@:forward
extern abstract RenderTarget(RenderTargetData) from RenderTargetData to RenderTargetData {
	/**
	 * Creates a render-target texture.
	 *
	 * The created texture is backed by a `Image` render target and can be used
	 * immediately as a draw destination.
	 *
	 * @param width RenderTarget width in pixels.
	 * @param height RenderTarget height in pixels.
	 * @param format Optional texture format.
	 * @param depthStencil Optional depth/stencil format.
	 * @param antiAliasingSamples Multisample count.
	 */
	overload public inline function new()
		this = new RenderTargetData();

	/**
	 * Creates a render-target texture.
	 *
	 * The created texture is backed by a `Image` render target and can be used
	 * immediately as a draw destination.
	 *
	 * @param width RenderTarget width in pixels.
	 * @param height RenderTarget height in pixels.
	 * @param format Optional texture format.
	 * @param depthStencil Optional depth/stencil format.
	 * @param antiAliasingSamples Multisample count.
	 */
	overload public inline function new(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, antiAliasingSamples:Int = 1) {
		this = new RenderTargetData();
		setParameters(width, height, format, depthStencil, antiAliasingSamples);
	}

	public inline function setParameters(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, antiAliasingSamples:Int = 1) {
		this.applyDepthStencilFormat(depthStencil);
		@:privateAccess this.image = kha.Image.createRenderTarget(width, height, format, depthStencil, antiAliasingSamples);
	}

	public inline function setDepthStencilFrom(image:Image) {
		@:privateAccess this.image.setDepthStencilFrom(image);
		this.inheritDepthStencilAttachment(image);
	}

	@:to
	private inline function toResource():kha.Image
		return @:privateAccess this.image;

	@:to
	private inline function toCanvas():kha.Canvas
		return toResource();

	@:to
	private inline function toAsset():s.assets.Image
		return this;
}

@:allow(s.graphics.RenderTarget)
private class RenderTargetData extends s.assets.internal.image.Image {
	public var depthStencilFormat(default, null):DepthStencilFormat = NoDepthAndStencil;
	public var hasDepthAttachment(default, null):Bool = false;
	public var hasStencilAttachment(default, null):Bool = false;

	/**
	 * 1D graphics context for this texture.
	 *
	 * Use this when you need low-level access to the 1D drawing API exposed by Kha.
	 */
	public var context1D(default, null):Context1D;

	/**
	 * 2D graphics context for this texture.
	 *
	 * This is the most common entry point when drawing UI, sprites, and text into
	 * an off-screen target.
	 */
	public var context2D(default, null):Context2D;

	/**
	 * 3D graphics context for this texture.
	 *
	 * Use this for custom GPU rendering passes targeting the texture.
	 */
	public var context3D(default, null):Context3D;

	override function unload() {
		if (!isLoaded)
			return;
		context1D = null;
		context2D = null;
		context3D = null;
		super.unload();
	}

	inline function applyDepthStencilFormat(?format:DepthStencilFormat) {
		depthStencilFormat = resolveDepthStencilFormat(format);
		hasDepthAttachment = formatHasDepth(depthStencilFormat);
		hasStencilAttachment = formatHasStencil(depthStencilFormat);
	}

	function inheritDepthStencilAttachment(image:Image) {
		final source:Dynamic = image;
		if (Std.isOfType(source, RenderTargetData)) {
			final target:RenderTargetData = cast source;
			depthStencilFormat = target.depthStencilFormat;
			hasDepthAttachment = target.hasDepthAttachment;
			hasStencilAttachment = target.hasStencilAttachment;
		} else
			applyDepthStencilFormat(DepthAutoStencilAuto);
	}

	static inline function resolveDepthStencilFormat(?format:DepthStencilFormat):DepthStencilFormat
		return format == null ? NoDepthAndStencil : format;

	static inline function formatHasDepth(format:DepthStencilFormat):Bool
		return format != NoDepthAndStencil;

	static inline function formatHasStencil(format:DepthStencilFormat):Bool
		return switch format {
			case DepthAutoStencilAuto, Depth24Stencil8, Depth32Stencil8: true;
			default: false;
		};

	@:slot(loaded)
	function updateContext()
		if (isLoaded) {
			context3D = new Context3D(image.g4, this);
			context2D = new Context2D(context3D);
			context1D = new Context1D(image);
		}
}
