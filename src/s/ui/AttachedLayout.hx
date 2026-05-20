package s.ui;

import s.ui.Element;
import s.ui.Alignment;

@:allow(s.ui.Element)
@:access(s.ui.Element)
class AttachedLayout extends s.shortcut.AttachedAttribute<Element> {
	var weight:Float = 0.0;
	@:attr(cell) var x:Float = 0.0;
	@:attr(cell) var y:Float = 0.0;
	@:attr(cell) var width:Float = 0.0;
	@:attr(cell) var height:Float = 0.0;

	@:attr(grid) @:clamp(0) public var row(default, set):Int = 0;
	@:attr(grid) @:clamp(1) public var rowSpan(default, set):Int = 1;
	@:attr(grid) @:clamp(0) public var column(default, set):Int = 0;
	@:attr(grid) @:clamp(1) public var columnSpan(default, set):Int = 1;

	@:attr public var alignment:Alignment = AlignLeft | AlignVCenter;

	@:attr(horizontal) public var fillWidth:Bool = false;
	@:attr(horizontal) public var minimumWidth:Float = 0.0;
	@:attr(horizontal) public var maximumWidth:Float = Math.POSITIVE_INFINITY;
	@:attr(horizontal) public var preferredWidth:Float = Math.NaN;
	@:attr(horizontal) public var horizontalStretchFactor:Float = 1.0;

	@:attr(vertical) public var fillHeight:Bool = false;
	@:attr(vertical) public var minimumHeight:Float = 0.0;
	@:attr(vertical) public var maximumHeight:Float = Math.POSITIVE_INFINITY;
	@:attr(vertical) public var preferredHeight:Float = Math.NaN;
	@:attr(vertical) public var verticalStretchFactor:Float = 1.0;

	inline function clampWidth(value:Float)
		return Math.min(Math.max(value, minimumWidth), maximumWidth);

	inline function clampHeight(value:Float)
		return Math.min(Math.max(value, minimumHeight), maximumHeight);

	@:access(s.ui.AttachedAnchorLine)
	inline function update() {
		final horizontalMargins = object.left.margin + object.right.margin;
		final verticalMargins = object.top.margin + object.bottom.margin;

		// fillWidth
		if (horizontalDirty && !Math.isNaN(preferredWidth))
			object.width = clampWidth(preferredWidth);
		else if (fillWidth
			&& (fillWidthDirty || horizontalStretchFactorDirty || widthDirty || object.left.marginDirty || object.right.marginDirty))
			object.width = clampWidth(Math.max(0.0, width * horizontalStretchFactor - horizontalMargins));

		// fillHeight
		if (verticalDirty && !Math.isNaN(preferredHeight))
			object.height = clampHeight(preferredHeight);
		else if (fillHeight
			&& (fillHeightDirty || verticalStretchFactorDirty || heightDirty || object.top.marginDirty || object.bottom.marginDirty))
			object.height = clampHeight(Math.max(0.0, height * verticalStretchFactor - verticalMargins));

		// AlignRight
		if ((alignmentDirty || xDirty || widthDirty || object.widthDirty || object.right.marginDirty) && alignment.matches(AlignRight))
			object.right.position = x + width - object.right.margin;
		// AlignHCenter
		else if ((alignmentDirty || xDirty || widthDirty || object.widthDirty || object.hCenter.marginDirty) && alignment.matches(AlignHCenter))
			object.hCenter.position = x + width * 0.5 + object.hCenter.margin;
		// fallback: AlignLeft
		else if (alignmentDirty || xDirty || object.left.marginDirty)
			object.left.position = x + object.left.margin;

		// AlignBottom
		if ((alignmentDirty || yDirty || heightDirty || object.heightDirty || object.bottom.marginDirty) && alignment.matches(AlignBottom))
			object.bottom.position = y + height - object.bottom.margin;
		// AlignHCenter
		else if ((alignmentDirty || yDirty || heightDirty || object.heightDirty || object.vCenter.marginDirty) && alignment.matches(AlignVCenter))
			object.vCenter.position = y + height * 0.5 + object.vCenter.margin;
		// fallback: AlignTop
		else if (alignmentDirty || yDirty || object.top.marginDirty)
			object.top.position = y + object.top.margin;
	}
}
