package s.ui.graphics.shapes;

import s.graphics.RenderTarget;
import s.graphics.ConstantLocation;
import s.ui.shapes.Triangle;

@:allow(s.ui.shapes.Triangle)
class TriangleDrawer extends ShapeDrawer<Triangle> {
	var point1CL:ConstantLocation;
	var point2CL:ConstantLocation;
	var point3CL:ConstantLocation;

	function new() {
		super("triangle");
	}

	override function setup() {
		super.setup();
		point1CL = pipeline.getConstantLocation("point1");
		point2CL = pipeline.getConstantLocation("point2");
		point3CL = pipeline.getConstantLocation("point3");
	}

	override function setUniforms(target:RenderTarget, element:Triangle) {
		super.setUniforms(target, element);
		final l = element.left.position;
		final t = element.top.position;
		final w = element.width;
		final h = element.height;
		final p1 = element.point1;
		final p2 = element.point2;
		final p3 = element.point3;
		final ctx = target.context3D;
		ctx.setVec2(point1CL, {x: l + p1.x * w, y: t + p1.y * h});
		ctx.setVec2(point2CL, {x: l + p2.x * w, y: t + p2.y * h});
		ctx.setVec2(point3CL, {x: l + p3.x * w, y: t + p3.y * h});
	}
}
