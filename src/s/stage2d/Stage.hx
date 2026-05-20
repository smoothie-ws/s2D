package s.stage2d;

import s.math.Vec2;
import s.math.Mat3;
import s.math.SMath;
import s.ui.elements.Canvas;
import s.stage2d.objects.Sprite;

@:allow(s.stage2d.graphics.StageDrawer)
class Stage extends Canvas {
	final sprites:Array<Sprite> = [];
	final viewProjection:Mat3 = new Mat3();

	public var stageScale(default, set):Float = 1.0;

	overload extern public inline function addChild(child:Sprite):Sprite {
		child.stage = this;
		return child;
	}

	overload extern public inline function removeChild(child:Sprite):Void
		child.stage = null;

	extern overload public inline function localToWorld(x:Float, y:Float):Vec2
		return localToWorld(vec2(x, y));

	extern overload public inline function localToWorld(point:Vec2):Vec2
		return (inverse(viewProjection) * vec3(point, 1.0)).xy;

	extern overload public inline function worldToLocal(x:Float, y:Float):Vec2
		return worldToLocal(vec2(x, y));

	extern overload public inline function worldToLocal(point:Vec2):Vec2
		return (viewProjection * vec3(point, 1.0)).xy;

	extern overload public inline function screenToLocal(x:Float, y:Float):Vec2
		return screenToLocal(vec2(x, y));

	extern overload public inline function screenToLocal(point:Vec2):Vec2
		return vec2(point.x / width * 2.0 - 1.0, 1.0 - point.y / height * 2.0);

	extern overload public inline function localToScreen(x:Float, y:Float):Vec2
		return localToScreen(vec2(x, y));

	extern overload public inline function localToScreen(point:Vec2):Vec2
		return vec2((point.x + 1.0) * width * 0.5, (1.0 - point.y) * height * 0.5);

	extern overload public inline function screenToWorld(x:Float, y:Float):Vec2
		return screenToWorld(vec2(x, y));

	extern overload public inline function screenToWorld(point:Vec2):Vec2
		return localToWorld(screenToLocal(point));

	extern overload public inline function worldToScreen(x:Float, y:Float):Vec2
		return worldToScreen(vec2(x, y));

	extern overload public inline function worldToScreen(point:Vec2):Vec2
		return localToScreen(worldToLocal(point));

	override function update() {
		super.update();

		if (widthDirty || heightDirty)
			updateViewProjection(width / height);

		s.stage2d.graphics.StageDrawer.shader.render(this);
	}

	function updateViewProjection(aspectRatio:Float) {
		var projection:Mat3;
		if (aspectRatio < 1)
			projection = Mat3.orthogonalProjection(-stageScale * aspectRatio, stageScale * aspectRatio, -stageScale, stageScale);
		else
			projection = Mat3.orthogonalProjection(-stageScale, stageScale, -stageScale / aspectRatio, stageScale / aspectRatio);
		viewProjection.setFrom(projection * Mat3.lookAt(vec2(0.0, 0.0), vec2(0.0, -1.0), vec2(0.0, 1.0)));
	}

	function set_stageScale(value:Float) {
		if (value != stageScale) {
			stageScale = value;
			updateViewProjection(width / height);
		}
		return stageScale;
	}
}
