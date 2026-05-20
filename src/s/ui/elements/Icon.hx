package s.ui.elements;

import s.assets.Image;
import s.graphics.RenderTarget;

class Icon<T:Image = Image> extends Textured<T> {
	/**
	 * Asset key or path of the image to display.
	 *
	 * Assigning this field forwards the value to the internal
	 * [`ImageAsset`](s.assets.ImageAsset). The exact naming scheme depends on the
	 * project's asset pipeline, but it typically matches the engine's image
	 * identifiers such as `"ui/logo"` or `"atlas/icons"`.
	 */
	@:alias public var source:T = texture;

	/**
	 * Creates a new image element bound to the given source asset.
	 *
	 * @param source Asset key or path used to resolve the image asset.
	 */
	public function new(?source:T) {
		super();
		this.source = source;
	}

	override function draw(target:RenderTarget) {
		if (!isLoaded)
			return;

		s.ui.graphics.IconDrawer.shader.render(target, cast this);
	}
}
