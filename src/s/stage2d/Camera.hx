package s.stage2d;

import s.math.Mat3;
import s.math.SMath;
import s.stage2d.objects.StageObject;

@:allow(s.stage2d.Stage)
class Camera extends StageObject {
	var view:Mat3 = Mat3.lookAt(vec2(0.0, 0.0), vec2(0.0, -1.0), vec2(0.0, 1.0));

	public function new() {
		super();
	}
}
