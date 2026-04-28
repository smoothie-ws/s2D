package s.ui;

import s.ui.Element;
import s.ui.AttachedAnchorLine;

@:allow(s.ui.Element)
class AttachedAnchors extends s.shortcut.AttachedAttribute<Element> {
	@:attr(horizontal) public var left:HorizontalAnchor;
	@:attr(horizontal) public var hCenter:HorizontalAnchor;
	@:attr(horizontal) public var right:HorizontalAnchor;
	@:attr(vertical) public var top:VerticalAnchor;
	@:attr(vertical) public var vCenter:VerticalAnchor;
	@:attr(vertical) public var bottom:VerticalAnchor;

	public function clear() {
		clearH();
		clearV();
	}

	public function clearH() {
		unfillWidth();
		hCenter = null;
	}

	public function clearV() {
		unfillHeight();
		vCenter = null;
	}

	overload extern public inline function fill(left:HorizontalAnchor, right:HorizontalAnchor, top:VerticalAnchor, bottom:VerticalAnchor) {
		fillWidth(left, right);
		fillHeight(top, bottom);
	}

	overload extern public inline function fill(element:{
		left:HorizontalAnchor,
		right:HorizontalAnchor,
		top:VerticalAnchor,
		bottom:VerticalAnchor
	})
		fill(element.left, element.right, element.top, element.bottom);

	overload extern public inline function fill(element:Element)
		fill(element.left, element.right, element.top, element.bottom);

	overload extern public inline function fillWidth(left:HorizontalAnchor, right:HorizontalAnchor) {
		this.left = left;
		this.right = right;
	}

	overload extern public inline function fillWidth(element:{left:HorizontalAnchor, right:HorizontalAnchor})
		fillWidth(element.left, element.right);

	overload extern public inline function fillWidth(element:Element)
		fillWidth(element.left, element.right);

	overload extern public inline function fillHeight(top:VerticalAnchor, bottom:VerticalAnchor) {
		this.top = top;
		this.bottom = bottom;
	}

	overload extern public inline function fillHeight(element:{
		top:VerticalAnchor,
		bottom:VerticalAnchor
	})
		fillHeight(element.top, element.bottom);

	overload extern public inline function fillHeight(element:Element)
		fillHeight(element.top, element.bottom);

	overload extern public inline function unfill() {
		unfillWidth();
		unfillHeight();
	}

	overload extern public inline function unfillWidth() {
		left = null;
		right = null;
	}

	overload extern public inline function unfillHeight() {
		top = null;
		bottom = null;
	}

	overload extern public inline function centerIn(hCenter:HorizontalAnchor, vCenter:VerticalAnchor) {
		this.hCenter = hCenter;
		this.vCenter = vCenter;
	}

	overload extern public inline function centerIn(element:{
		hCenter:HorizontalAnchor,
		vCenter:VerticalAnchor
	})
		centerIn(element.hCenter, element.vCenter);

	overload extern public inline function centerIn(element:Element)
		centerIn(element.hCenter, element.vCenter);

	function update() {
		if (left != null && (leftDirty || left.offsetDirty || object.left.marginDirty))
			object.left.position = left.position + left.padding + object.left.margin;
		if (hCenter != null && (hCenterDirty || hCenter.offsetDirty || object.hCenter.marginDirty))
			object.hCenter.position = hCenter.position + hCenter.padding + object.hCenter.margin;
		if (right != null && (rightDirty || right.offsetDirty || object.right.marginDirty))
			object.right.position = right.position - right.padding - object.right.margin;
		if (top != null && (topDirty || top.offsetDirty || object.top.marginDirty))
			object.top.position = top.position + top.padding + object.top.margin;
		if (vCenter != null && (vCenterDirty || vCenter.offsetDirty || object.vCenter.marginDirty))
			object.vCenter.position = vCenter.position + vCenter.padding + object.vCenter.margin;
		if (bottom != null && (bottomDirty || bottom.offsetDirty || object.bottom.marginDirty))
			object.bottom.position = bottom.position - bottom.padding - object.bottom.margin;
	}

	function set_left(value:HorizontalAnchor):HorizontalAnchor {
		if (left == value)
			return left;
		if (left != null)
			left.removeDependent(object);
		left = value;
		if (left != null)
			left.addDependent(object);
		return left;
	}

	function set_hCenter(value:HorizontalAnchor):HorizontalAnchor {
		if (hCenter == value)
			return hCenter;
		if (hCenter != null)
			hCenter.removeDependent(object);
		hCenter = value;
		if (hCenter != null)
			hCenter.addDependent(object);
		return hCenter;
	}

	function set_right(value:HorizontalAnchor):HorizontalAnchor {
		if (right == value)
			return right;
		if (right != null)
			right.removeDependent(object);
		right = value;
		if (right != null)
			right.addDependent(object);
		return right;
	}

	function set_top(value:VerticalAnchor):VerticalAnchor {
		if (top == value)
			return top;
		if (top != null)
			top.removeDependent(object);
		top = value;
		if (top != null)
			top.addDependent(object);
		return top;
	}

	function set_vCenter(value:VerticalAnchor):VerticalAnchor {
		if (vCenter == value)
			return vCenter;
		if (vCenter != null)
			vCenter.removeDependent(object);
		vCenter = value;
		if (vCenter != null)
			vCenter.addDependent(object);
		return vCenter;
	}

	function set_bottom(value:VerticalAnchor):VerticalAnchor {
		if (bottom == value)
			return bottom;
		if (bottom != null)
			bottom.removeDependent(object);
		bottom = value;
		if (bottom != null)
			bottom.addDependent(object);
		return bottom;
	}
}
