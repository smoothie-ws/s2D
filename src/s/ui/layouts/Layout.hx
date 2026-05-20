package s.ui.layouts;

import s.ui.Element;

@:access(s.ui.AttachedLayout)
@:access(s.ui.Element)
class Layout extends Element {
	final cells:Array<AttachedLayout> = [];
	@:attr(rect) var rectX:Float = 0.0;
	@:attr(rect) var rectY:Float = 0.0;
	@:attr(rect) var rectWidth:Float = 0.0;
	@:attr(rect) var rectHeight:Float = 0.0;

	@:readonly @:alias public var availableWidth:Float = rectWidth;
	@:readonly @:alias public var availableHeight:Float = rectHeight;

	override function update() {
		super.update();

		if (left.offsetDirty || right.offsetDirty) {
			if (left.offsetDirty)
				rectX = left.position + left.padding;
			rectWidth = width - left.padding - right.padding;
		}
		if (top.offsetDirty || bottom.offsetDirty) {
			if (top.offsetDirty)
				rectY = top.position + top.padding;
			rectHeight = height - top.padding - bottom.padding;
		}
	}

	override function updateChildren()
		if (children.dirty) {
			cells.resize(0);
			for (c in children)
				pushCell(c);
		} else {
			var i = 0;
			while (i < cells.length && syncCell(i))
				i++;
		}

	function pushCell(c:Element) {
		if (!c.isVisible)
			return;

		final cell = c.layout;
		cells.push(cell);
		cell.x = rectX;
		cell.y = rectY;
		cell.width = rectWidth;
		cell.height = rectHeight;
		updateCell(cell);
	}

	function syncCell(i:Int) {
		final cell = cells[i];

		if (!cell.object.isVisible) {
			cells.splice(i, 1);
			return false;
		}

		if (rectDirty) {
			if (rectXDirty)
				cell.x = rectX;
			if (rectYDirty)
				cell.y = rectY;
			if (rectWidthDirty)
				cell.width = rectWidth;
			if (rectHeightDirty)
				cell.height = rectHeight;
		}

		updateCell(cell);

		return true;
	}

	override function updateChildDependencies(child:Element) {
		if (child.parentDirty)
			insertChild(child);
		if (child.parentDirty || sceneDirty)
			setChildScene(child);
		if (child.parentDirty || layerDirty)
			setChildLayer(child);
	}

	function updateCell(cell:AttachedLayout) {
		if (cell.dirty
			|| cell.object.widthDirty
			|| cell.object.heightDirty
			|| cell.object.left.marginDirty
			|| cell.object.right.marginDirty
			|| cell.object.top.marginDirty
			|| cell.object.bottom.marginDirty)
			cell.update();
		updateChild(cell.object);
	}
}
