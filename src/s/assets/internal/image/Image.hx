package s.assets.internal.image;

class Image extends Asset<kha.Image> implements s.shortcut.Shortcut {
	var image(default, set):kha.Image;

	@:readonly @:alias public var width:Int = image?.width;
	@:readonly @:alias public var height:Int = image?.height;

	public function generateMipmaps(levels:Int)
		image.generateMipmaps(levels);

	public function setMipmaps(mipmaps:Array<Image>)
		image.setMipmaps(mipmaps.map(m -> m.image));

	function unload() {
		if (!isLoaded)
			return;

		final resource = image;
		@:bypassAccessor image = null;
		resource.unload();
	}

	function fromResource(resource:kha.Image):Void
		image = resource;

	function toResource():kha.Image
		return image;

	inline function set_image(value:kha.Image) {
		if (image == value)
			return image;

		image?.unload();
		@:bypassAccessor image = value;
		if (image != null)
			notifyLoaded();
		return image;
	}

	function get_isLoaded():Bool
		return image != null;
}
