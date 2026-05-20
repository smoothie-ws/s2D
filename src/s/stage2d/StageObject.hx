package s.stage2d;

abstract class StageObject extends s.Object2D<StageObject> {
	public var stage(default, set):Stage;

	@:alias public var x:Float = this.translationX;
	@:alias public var y:Float = this.translationY;

	public function addToStage(stage:Stage)
		this.stage = stage;

	abstract function set_stage(value:Stage):Stage;

	override function set_dirty(value:Bool) {
		if (value && parent?.dirty != true && stage != null && !stage.dirty)
			stage.markDirty();
		return super.set_dirty(value);
	}
}
