package s.ui.elements;

import s.ui.elements.Drawable;

@:allow(s.ui.elements.Drawable)
class Layer extends Canvas {
	var paintDirty:Bool = false;

	final drawable:Array<Drawable> = [];

	public var isLive:Bool = true;

	override function setChildLayer(child:Element)
		@:bypassAccessor child.layer = this;

	override function update() {
		super.update();
		paintDirty = dirty;
	}

	override function updateOrder() {
		super.updateOrder();
		if (children.dirty)
			drawable.resize(0);
	}

	override function updateTree() {
		super.updateTree();

		if (!paintDirty)
			return;

		paintDirty = false;
		if (isLive)
			paint(_ -> for (el in drawable)
				el.draw(texture));
	}
}
