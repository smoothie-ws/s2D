package s.assets.internal.sound;

class Sound extends Asset<kha.Sound> {
	var sound:kha.Sound;

	public function unload():Void {
		sound?.unload();
		sound = null;
	}

	function fromResource(resource:T):Void
		sound = resource;

	function toResource():T
		return sound;

	function get_isLoaded():Bool
		return sound != null;
}
