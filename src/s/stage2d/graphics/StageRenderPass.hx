package s.stage2d.graphics;

import s.graphics.shaders.Shader;
import s.stage2d.Stage;

@:dox(hide)
abstract class StageRenderPass extends Shader {
	abstract function render(stage:Stage):Void;
}
