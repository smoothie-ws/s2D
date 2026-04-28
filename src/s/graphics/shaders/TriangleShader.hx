package s.graphics.shaders;

import s.graphics.ConstantLocation;

class TriangleShader extends Shader2D {
	public function render(context:Context2D, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float) {
		super.set(context);
		final ctx = context.context;
		ctx.addPolygon([[x1, y1, 0.0, 0.0], [x2, y2, 0.5, 1.0], [x3, y3, 1.0, 0.0]]);
		ctx.flush();
	}
}
