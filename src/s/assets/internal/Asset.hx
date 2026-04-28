package s.assets.internal;

@:allow(s.assets.AssetList)
@:allow(s.macro.AssetsMacro)
abstract class Asset<T:Resource> implements s.shortcut.Shortcut {
	public final name:String;
	public var location:AssetLocation;
	public var version:String;

	public var isLoaded(get, never):Bool;

	var deferLoadedSignal:Bool = false;

	@:signal public function loaded():Void;

	function new(?name:String)
		this.name = name;

	inline function notifyLoaded():Void
		if (!deferLoadedSignal)
			loaded();

	abstract public function unload():Void;

	abstract function fromResource(resource:T):Void;

	abstract function toResource():T;

	abstract function get_isLoaded():Bool;
}
