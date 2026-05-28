package s.ui;

import s.math.Mat3;
import s.math.SMath;
import s.geometry.Size;
import s.geometry.Position;
import s.ui.Alignment;
import s.ui.AttachedLayout;
import s.ui.AttachedAnchors;
import s.ui.AttachedAnchorLine;
import s.ui.elements.Layer;
#if debug_element_bounds
import s.graphics.Context2D;

using s.extensions.StringExt;
#end

@:allow(s.ui.Scene)
class Element extends Object2D<Element> implements Markup {
	overload extern public static inline function mapToElement(element:Element, x:Float, y:Float):Position
		return element.mapFromGlobal(x, y);

	overload extern public static inline function mapToElement(element:Element, p:Position):Position
		return element.mapFromGlobal(p.x, p.y);

	overload extern public static inline function mapFromElement(element:Element, x:Float, y:Float):Position
		return element.mapToGlobal(x, y);

	overload extern public static inline function mapFromElement(element:Element, p:Position):Position
		return element.mapToGlobal(p.x, p.y);

	overload extern public static inline function mapToElementNormalized(element:Element, x:Float, y:Float):Position
		return element.mapFromGlobalNormalized(x, y);

	overload extern public static inline function mapToElementNormalized(element:Element, p:Position):Position
		return element.mapFromGlobalNormalized(p.x, p.y);

	overload extern public static inline function mapFromElementNormalized(element:Element, x:Float, y:Float):Position
		return element.mapToGlobalNormalized(x, y);

	overload extern public static inline function mapFromElementNormalized(element:Element, p:Position):Position
		return element.mapToGlobalNormalized(p.x, p.y);

	overload extern public static inline function align(alignment:Alignment, element:Element, ?h:Float = 0.0, ?v:Float = 0.0) {
		// horizontal
		if (alignment.matches(AlignLeft))
			element.x = h;
		else if (alignment.matches(AlignHCenter))
			element.x = h - element.width * 0.5;
		else if (alignment.matches(AlignRight))
			element.x = h - element.width;
		// vertical
		if (alignment.matches(AlignTop))
			element.y = v;
		else if (alignment.matches(AlignVCenter))
			element.y = v - element.height * 0.5;
		else if (alignment.matches(AlignBottom))
			element.y = v - element.height;
	}

	overload extern public static inline function align(alignment:Alignment, elements:Array<Element>, ?h:Float = 0.0, ?v:Float = 0.0) {
		// horizontal
		if (alignment.matches(AlignLeft))
			for (element in elements)
				element.x = h;
		else if (alignment.matches(AlignHCenter))
			for (element in elements)
				element.x = h - element.width * 0.5;
		else if (alignment.matches(AlignRight))
			for (element in elements)
				element.x = h - element.width;
		// vertical
		if (alignment.matches(AlignTop))
			for (element in elements)
				element.y = v;
		else if (alignment.matches(AlignVCenter))
			for (element in elements)
				element.y = v - element.height * 0.5;
		else if (alignment.matches(AlignBottom))
			for (element in elements)
				element.y = v - element.height;
	}

	final realTransformInverted:Mat3 = new Mat3();
	@:attr var realTransform:Mat3 = new Mat3();
	@:attr var realOpacity:Float = 1.0;
	@:attr var realVisible:Bool = true;
	@:attr(realOrigin) var realOriginX:Float = 0.0;
	@:attr(realOrigin) var realOriginY:Float = 0.0;

	@:attr public var scene(default, set):Scene;
	@:attr public var layer(default, set):Layer;

	/**
	 * Optional application-defined tag used for lookup.
	 *
	 * Tags are not required to be unique. Methods such as
	 * [`getChild`](s.ui.Element.getChild), [`getChildren`](s.ui.Element.getChildren), and
	 * [`findChild`](s.ui.Element.findChild) use this field for simple structural
	 * queries.
	 */
	@:attr.attached public var tags(default, set):ElementTags;

	@:attr public var clip:Bool = false; // TODO: stencil test (?)
	@:attr.attached public final layout:AttachedLayout;

	@:attr(visibility) @:clamp public var opacity:Float = 1.0;
	@:attr(visibility) public var isVisible:Bool = true;

	public var padding(never, set):Float;
	public var margins(never, set):Float;
	@:attr.attached public final anchors:AttachedAnchors;

	@:attr.attached public final left:HorizontalAnchor;
	@:attr.attached public final hCenter:HorizontalAnchor;
	@:attr.attached public final right:HorizontalAnchor;
	@:attr.attached public final top:VerticalAnchor;
	@:attr.attached public final vCenter:VerticalAnchor;
	@:attr.attached public final bottom:VerticalAnchor;

	@:attr(horizontal) public var x(default, set):Float = 0.0;
	@:attr(vertical) public var y(default, set):Float = 0.0;
	@:attr(horizontal) public var width(default, set):Float = 0.0;
	@:attr(vertical) public var height(default, set):Float = 0.0;

	@:attr(origin) public var originX:Float = Math.NaN;
	@:attr(origin) public var originY:Float = Math.NaN;

	@:attr(transform) public var inheritTransform:Bool = true;
	@:attr(transform) public var propagateTransform:Bool = true;

	@:signal public function updated();

	public function new(?tags:ElementTags) {
		super();

		if (tags == null)
			tags = "";
		this.tags = tags;

		layout = new AttachedLayout(this);
		anchors = new AttachedAnchors(this);

		left = new HorizontalAnchor(this);
		hCenter = new HorizontalAnchor(this);
		right = new HorizontalAnchor(this);
		top = new VerticalAnchor(this);
		vCenter = new VerticalAnchor(this);
		bottom = new VerticalAnchor(this);

		markup(this);
	}

	public function setOpacity(value:Float):Float
		return opacity = value;

	overload extern public inline function setPadding(value:Float):Void
		setPadding(value, value, value, value);

	overload extern public inline function setPadding(left:Float, top:Float, right:Float, bottom:Float):Void {
		this.left.padding = left;
		this.top.padding = top;
		this.right.padding = right;
		this.bottom.padding = bottom;
	}

	overload extern public inline function setMargins(value:Float):Void
		setMargins(value, value, value, value);

	overload extern public inline function setMargins(left:Float, top:Float, right:Float, bottom:Float):Void {
		this.left.margin = left;
		this.top.margin = top;
		this.right.margin = right;
		this.bottom.margin = bottom;
	}

	overload extern public inline function setSize(size:Size):Void
		setSize(size.width, size.height);

	overload extern public inline function setSize(width:Float, height:Float):Void {
		this.width = width;
		this.height = height;
	}

	overload extern public inline function setPosition(position:Position):Void
		setPosition(position.x, position.y);

	overload extern public inline function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}

	overload extern public inline function setOrigin(origin:Position):Void
		setOrigin(origin.x, origin.y);

	overload extern public inline function setOrigin(x:Float, y:Float):Void {
		originX = x;
		originY = y;
	}

	overload extern public inline function mapFromGlobal(x:Float, y:Float):Position
		return mapFromGlobal(vec2(x, y));

	overload extern public inline function mapFromGlobal(p:Position):Position
		return realTransform * p - vec2(left.position, top.position);

	overload extern public inline function mapToGlobal(x:Float, y:Float):Position
		return mapToGlobal(vec2(x, y));

	overload extern public inline function mapToGlobal(p:Position):Position
		return realTransformInverted * p;

	overload extern public inline function mapFromGlobalNormalized(x:Float, y:Float):Position
		return mapFromGlobalNormalized(vec2(x, y));

	overload extern public inline function mapFromGlobalNormalized(p:Position):Position
		return mapFromGlobal(p) / vec2(width, height);

	overload extern public inline function mapToGlobalNormalized(x:Float, y:Float):Position
		return mapToGlobalNormalized(vec2(x, y));

	overload extern public inline function mapToGlobalNormalized(p:Position):Position
		return mapToGlobal(p) / vec2(width, height);

	overload extern public inline function covers(x:Float, y:Float):Bool
		return covers(vec2(x, y));

	overload extern public inline function covers(p:Position):Bool
		return contains(mapToGlobal(p));

	overload extern public inline function contains(p:Position):Bool
		return contains(p.x, p.y);

	overload extern public inline function contains(x:Float, y:Float):Bool
		return left.position <= x && x <= right.position && top.position <= y && y <= bottom.position;

	public inline function hasTag(tag:String):Bool
		return tags.has(tag);

	public inline function addTag(tag:String):Void
		tags.add(tag);

	public inline function removeTag(tag:String):Void
		tags.remove(tag);

	/**
	 * Returns the first direct child with the given tag.
	 *
	 * This only checks direct children and does not recurse into descendants.
	 *
	 * @param tag Tag to match.
	 * @return The found child or `null`.
	 */
	public function getChild(tag:String):Element {
		for (c in children)
			if (c.tags.has(tag))
				return c;
		return null;
	}

	/**
	 * Returns all direct children with the given tag.
	 *
	 * This only checks direct children and does not recurse into descendants.
	 *
	 * @param tag Tag to match.
	 * @return Matching direct children.
	 */
	public function getChildren(tag:String):Array<Element>
		return children.filter(c -> c.hasTag(tag));

	/**
	 * Searches the full descendant tree for the first node with the given tag.
	 *
	 * Search order is depth-first in child order.
	 *
	 * @param tag Tag to match.
	 * @return The found descendant or `null`.
	 */
	public function findChild(tag:String):Element {
		for (child in children)
			if (child.hasTag(tag))
				return child;
			else {
				var c = child.findChild(tag);
				if (c != null)
					return c;
			}
		return null;
	}

	public function childAt(x:Float, y:Float):Element {
		var i = children.count;
		while (0 < i) {
			final c = children[--i];
			if (c.covers(x, y))
				return c;
		}
		return null;
	}

	public function descendantAt(x:Float, y:Float):Element {
		var i = children.count;
		while (0 < i) {
			final c = children[--i];
			var cat = c.descendantAt(x, y);
			if (cat == null) {
				if (c.covers(x, y))
					return c;
			} else
				return cat;
		};
		return null;
	}

	override function toString():String
		return super.toString() + tags.toString();

	@:ui.markup
	function markup() {}

	function updateTree() {
		updated();
		update();
		updateChildren();
		flush();
	}

	function updateChildren()
		for (c in children)
			updateChild(c);

	function updateChild(child:Element) {
		if (!isChildDirty(child))
			return;
		updateChildDependencies(child);
		child.updateTree();
	}

	function updateChildDependencies(child:Element) {
		if (child.parentDirty)
			insertChild(child);
		if (child.parentDirty || sceneDirty)
			setChildScene(child);
		if (child.parentDirty || layerDirty)
			setChildLayer(child);
		if (!child.isHorizontallyAnchored() && left.positionDirty)
			child.left.position = child.x + left.position;
		if (!child.isVerticallyAnchored() && top.positionDirty)
			child.top.position = child.y + top.position;
	}

	function update() {
		anchors.update();

		s.ui.macro.ElementMacro.updateAxis("left", "hCenter", "right", "x", "width");
		s.ui.macro.ElementMacro.updateAxis("top", "vCenter", "bottom", "y", "height");

		if (horizontalDirty || originDirty)
			realOriginX = left.position + (Math.isNaN(originX) ? width * 0.5 : originX);
		if (verticalDirty || originDirty)
			realOriginY = top.position + (Math.isNaN(originY) ? height * 0.5 : originY);

		if (realOriginDirty || transformDirty || parentDirty || parent?.realTransformDirty) {
			realTransform = Mat3.translation(-realOriginX, -realOriginY) * transform * Mat3.translation(realOriginX, realOriginY);
			if (parent != null && parent.propagateTransform && inheritTransform)
				realTransform *= parent.realTransform;
			realTransformInverted.setFrom(inverse(realTransform));
		}

		if (visibilityDirty || parentDirty || parent?.realOpacityDirty) {
			realOpacity = opacity;
			if (parent != null)
				realOpacity = parent.realOpacity * realOpacity;
		}

		if (visibilityDirty || parentDirty || parent?.realVisibleDirty || realOpacityDirty) {
			realVisible = isVisible && realOpacity > 0.0;
			if (parent != null)
				realVisible = parent.realVisible && realVisible;
		}
	}

	function isChildDirty(child:Element):Bool
		return child.dirty
			|| realVisibleDirty
			|| realOpacityDirty
			|| realTransformDirty
			|| scene?.children.dirty
			|| layer?.children.dirty;

	function setChildScene(child:Element)
		@:bypassAccessor child.scene = scene;

	function setChildLayer(child:Element)
		@:bypassAccessor child.layer = layer;

	#if debug_element_bounds
	function drawBounds(ctx:Context2D) {
		final style = ctx.style;

		style.opacity = 0.5;
		style.font.setDefault();
		style.font.family = "default";
		style.font.size = 16;

		final lm = left.margin;
		final tm = top.margin;
		final rm = right.margin;
		final bm = bottom.margin;
		final lp = left.padding;
		final tp = top.padding;
		final rp = right.padding;
		final bp = bottom.padding;

		style.color = Black;
		ctx.fillRectangle(left.position - lm, top.position - tm, width + lm + rm, height + tm + bm);

		// margins
		style.color = s.Color.rgb(0.75, 0.25, 0.75);
		ctx.fillRectangle(left.position - lm, top.position, lm, height);
		ctx.fillRectangle(left.position - lm, top.position - tm, lm + width + rm, tm);
		ctx.fillRectangle(left.position + width, top.position, rm, height);
		ctx.fillRectangle(left.position - lm, top.position + height, lm + width + rm, bm);

		// padding
		style.color = s.Color.rgb(0.75, 0.75, 0.25);
		ctx.fillRectangle(left.position, top.position, lp, height);
		ctx.fillRectangle(left.position + lp, top.position, width - lp - rp, tp);
		ctx.fillRectangle(left.position + width - rp, top.position, rp, height);
		ctx.fillRectangle(left.position + lp, top.position + height - bp, width - lp - rp, bp);

		// content
		style.color = s.Color.rgb(0.25, 0.75, 0.75);
		ctx.fillRectangle(left.position + lp, top.position + tp, width - lp - rp, height - tp - bp);

		// labels
		style.color = s.Color.rgb(1.0, 1.0, 1.0);
		style.opacity = 1.0;
		final fs = style.font.size + 5;

		// labels - titles
		if (tm >= fs)
			ctx.drawString("margins", left.position - lm + 5, top.position - tm + 5);
		if (tp >= fs)
			ctx.drawString("padding", left.position + 5, top.position + 5);
		if (height >= fs)
			ctx.drawString("content", left.position + lp + 5, top.position + tp + 5);

		// labels - values
		style.font.size = 14;

		// margins
		var i = 0;
		for (m in [lm, tm, rm, bm]) {
			final str = '${Std.int(m)}px';
			final strWidth = style.font.widthOfCharacters(str.toCharArray(), 0, str.length);
			final strheight = style.font.size;
			if (m >= strWidth) {
				if (i == 0)
					ctx.drawString(str, left.position - (m + strWidth) / 2, top.position + height / 2);
				else if (i == 2)
					ctx.drawString(str, left.position + width + (m - strWidth) / 2, top.position + height / 2);
			}
			if (m >= strheight) {
				if (i == 1)
					ctx.drawString(str, left.position + width / 2, top.position - (m + strheight) / 2);
				else if (i == 3)
					ctx.drawString(str, left.position + width / 2, top.position + height + (m - strheight) / 2);
			}
			++i;
		}

		// padding
		var i = 0;
		for (p in [lp, tp, rp, bp]) {
			final str = '${Std.int(p)}px';
			final strWidth = style.font.widthOfCharacters(str.toCharArray(), 0, str.length);
			final strheight = style.font.size;
			if (p >= strWidth) {
				if (i == 0)
					ctx.drawString(str, left.position + (p - strWidth) / 2, top.position + height / 2);
				else if (i == 2)
					ctx.drawString(str, left.position + width - (p + strWidth) / 2, top.position + height / 2);
			}
			if (p >= strheight) {
				if (i == 1)
					ctx.drawString(str, left.position + width / 2, top.position + (p - strheight) / 2);
				else if (i == 3)
					ctx.drawString(str, left.position + width / 2, top.position + height - (p + strheight) / 2);
			}
			++i;
		}

		style.font.size = 22;
		final name = toString();
		ctx.drawString(name, App.input.mouse.x - style.font.widthOfCharacters(name.toCharArray(), 0, name.length), App.input.mouse.y - style.font.size);

		style.font.size = 16;
		final rect = '${Std.int(width)} × ${Std.int(height)} at (${Std.int(left.position)}, ${Std.int(top.position)})';
		ctx.drawString(rect, App.input.mouse.x - style.font.widthOfCharacters(rect.toCharArray(), 0, rect.length), App.input.mouse.y);
	}
	#end

	function set_scene(value:Scene):Scene {
		parent = value;
		return scene = value;
	}

	function set_layer(value:Layer):Layer {
		parent = value;
		return layer = value;
	}

	function set_tags(value:ElementTags):ElementTags
		return tags = new ElementTags(value.tags, this); // error: s.ui.Element.A should be s.ui.ElementAttributes

	function set_x(value:Float):Float {
		if (!isHorizontallyAnchored())
			x = value;
		return x;
	}

	function set_y(value:Float):Float {
		if (!isVerticallyAnchored())
			y = value;
		return y;
	}

	function set_width(value:Float):Float {
		if (!isHorizontallyLocked())
			width = value;
		return width;
	}

	function set_height(value:Float):Float {
		if (!isVerticallyLocked())
			height = value;
		return height;
	}

	function set_padding(value:Float):Float {
		setPadding(value);
		return value;
	}

	function set_margins(value:Float):Float {
		setMargins(value);
		return value;
	}

	inline function isHorizontallyAnchored()
		return anchors.left != null || anchors.hCenter != null || anchors.right != null;

	inline function isVerticallyAnchored()
		return anchors.top != null || anchors.vCenter != null || anchors.bottom != null;

	inline function isHorizontallyLocked()
		return (anchors.left != null && anchors.hCenter != null || anchors.left != null && anchors.right != null || anchors.hCenter != null
			&& anchors.right != null);

	inline function isVerticallyLocked()
		return (anchors.top != null && anchors.vCenter != null || anchors.top != null && anchors.bottom != null || anchors.vCenter != null
			&& anchors.bottom != null);
}
