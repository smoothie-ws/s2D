package s.ui.controls;

import s.math.SMath;
import s.ui.shapes.Rectangle;
import s.ui.elements.Control;

class Slider extends Control<Rectangle, Rectangle> {
	@:inject(updatePosition) @:attr public var from(default, set):Float = 0.0;
	@:inject(updatePosition) @:attr public var to(default, set):Float = 1.0;
	@:attr public var value(default, set):Float;
	@:attr public var position(default, set):Float = 0.5;
	@:attr public var snapMode:SnapMode = NoSnap;
	@:attr public var snapStep:Float = 0.0;

	@:attr public var orientation(default, set):Orientation;

	@:signal public function valueChanged(value:Float);

	public function new() {
		super(new Rectangle(), new Rectangle());
		this.orientation = Horizontal;
	}

	@:slot(mousePressed)
	function updateMousePressed(_) {
		setPressPosition(pressX, pressY);
		scene.window.mouse.onMoved(setMovedPosition);
	}

	@:slot(mouseReleased)
	function updateMouseReleased(_) {
		if (snapMode == SnapOnRelease)
			snapValue();
		scene.window.mouse.offMoved(setMovedPosition);
	}

	function setMovedPosition(x:Float, y:Float, dx:Float, dy:Float)
		setPressPosition(x - content.left.position, y - content.right.position);

	function setPressPosition(x:Float, y:Float)
		position = switch orientation {
			case Horizontal: width > 0 ? x / width : 0;
			case Vertical: height > 0 ? y / height : 0;
		}

	function updateValue() {
		@:bypassAccessor value = (to - from) * position + from;
		valueChanged(value);
		valueDirty = true;
	}

	function updatePosition() {
		if (to == from)
			@:bypassAccessor position = value <= from ? 0.0 : 1.0;
		else
			@:bypassAccessor position = clamp((value - from) / (to - from), 0.0, 1.0);
		positionDirty = true;
	}

	function snapValue()
		if (snapStep > 0)
			value = Math.round(value * (1 / snapStep)) * snapStep;

	override function update() {
		super.update();

		switch orientation {
			case Horizontal:
				if (positionDirty || widthDirty || content.left.marginDirty || content.right.marginDirty)
					content.width = position * (width - leftPadding - rightPadding);
			case Vertical:
				if (positionDirty || heightDirty || content.top.marginDirty || content.bottom.marginDirty)
					content.height = position * (height - topPadding - bottomPadding);
		}
	}

	override function destroy() {
		super.destroy();
		valueChanged.destroy();
	}

	function set_value(v:Float) {
		if (value != v) {
			value = clamp(v, from, to);
			updatePosition();
			valueChanged(value);
		}
		return value;
	}

	function set_position(p:Float) {
		if (position != p) {
			position = clamp(p, 0.0, 1.0);
			updateValue();
			if (snapMode == SnapAlways)
				snapValue();
		}
		return position;
	}

	function set_orientation(o:Orientation) {
		if (orientation != o) {
			content.anchors.clear();
			switch orientation = o {
				case Horizontal:
					content.anchors.top = top;
					content.anchors.left = left;
					content.anchors.bottom = bottom;
					content.width = position * (width - leftPadding - rightPadding);
				case Vertical:
					content.anchors.top = top;
					content.anchors.left = left;
					content.anchors.right = right;
					content.height = position * (height - topPadding - bottomPadding);
			}
		}
		return orientation;
	}
}
