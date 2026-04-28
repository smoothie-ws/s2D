package s.stage2d.graphics.postprocessing;

import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import s.graphics.RenderTarget;

// @:access(s.stage2d.graphics.Renderer)
abstract class PPEffect {
	var pipeline:PipelineState;
	var index:Int;

	public var enabled(get, set):Bool;

	public function new() {}

	public function enable() {
		enabled = true;
	}

	public function disable() {
		enabled = false;
	}

	abstract function setPipeline():Void;

	abstract function getUniforms():Void;

	public function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		setPipeline();
		pipeline.compile();
		getUniforms();
	}

	abstract public function render(target:RenderTarget):Void;

	public function command():Void {
		// Renderer.buffer.swap();
		// render(Renderer.buffer.tgt);
	}

	function get_enabled():Bool {
		// return Renderer.commands.contains(command);
		return true;
	}

	function set_enabled(value:Bool):Bool {
		// if (!enabled && value)
		// 	Renderer.commands.insert(index, command);
		return enabled;
	}
}
