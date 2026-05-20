package s.stage2d.objects;

import s.assets.Image;
import s.geometry.Rect;

@:access(s.stage2d.Stage)
class Sprite extends StageObject {
	public var source:Image;
	public var sourceClipRect:Rect = new Rect(0.0, 0.0, 1.0, 1.0);

	public function new(source:String) {
		super();
		this.source = source;
	}

	function set_stage(value:Stage):Stage {
		if (value != stage) {
			if (stage?.sprites.contains(this) == true)
				stage.sprites.remove(this);
			if (value?.sprites.contains(this) == false)
				value.sprites.push(this);
			stage = value;
		}
		return stage;
	}
}
