package s.ui.elements;

import s.ui.Alignment;
import s.graphics.FontStyle;

using StringTools;

@:allow(s.ui.graphics.TextDrawer)
@:access(s.graphics.FontStyle)
class Label extends Drawable {
	var chars:Array<FontChar> = [];
	var lineChars:Array<FontChar> = [];
	var ellipsisChars:Array<FontChar> = [];
	var lineWidth:Float = 0.0;

	@:attr(textHorizontal) var textX:Float = 0.0;
	@:attr(textVertical) var textY:Float = 0.0;
	@:attr(textHorizontal) var textWidth:Float = 0.0;

	@:attr.attached public final font:FontStyle = new FontStyle();

	@:attr(content) public var text:String;
	@:attr(content) public var elideMode:ElideMode = ElideNone;
	@:attr public var alignment:Alignment = AlignLeft | AlignTop;

	@:readonly @:alias public var displayX:Float = textX;
	@:readonly @:alias public var displayY:Float = textY;
	@:readonly @:alias public var displayWidth:Float = textWidth;
	@:readonly @:alias public var displayHeight:Float = font.size;

	public function new(text:String = "") {
		super();
		color = Black;
		this.text = text;
	}

	function draw(target:s.graphics.RenderTarget) {
		if (text.length == 0 || !font.isLoaded || font.size == 0)
			return;
		final ctx = target.context2D;
		ctx.pushTransform(realTransform);
		ctx.style.color = realColor;
		ctx.style.font.copyFrom(font);
		ctx.drawFontChars(chars);
		ctx.popTransform();
	}

	override function update():Void {
		super.update();

		if (text.length == 0 || !font.isLoaded || font.size == 0)
			return;

		final hDirty = left.offsetDirty || right.offsetDirty;
		final vDirty = top.offsetDirty || bottom.offsetDirty;
		final lineCharsDirty = contentDirty || font.spacingDirty || font.metricsDirty;
		final charsAreDirty = lineCharsDirty || elideMode != ElideNone && hDirty;

		if (lineCharsDirty)
			rebuildLineChars();
		if (charsAreDirty)
			textWidth = elideLineChars();

		if (textHorizontalDirty || font.metricsDirty || hDirty || vDirty || alignmentDirty) {
			textX = alignLineX(textWidth);
			textY = alignLineY(font.size);
		}

		if (charsAreDirty || textHorizontalDirty)
			alignCharsX(textX);
		if (charsAreDirty || textVerticalDirty)
			alignCharsY(textY);
	}

	function alignCharsX(offset:Float)
		for (c in chars) {
			c.pos.x = offset + c.xoff;
			offset += c.advance;
		}

	function alignCharsY(offset:Float) {
		final snappedOffset = font.snapToPixel ? Math.round(offset) : offset;
		for (c in chars)
			c.pos.y = snappedOffset + c.yoff;
	}

	function alignLineX(width:Float)
		return alignment & AlignRight != 0 ? right.position - right.padding - width : alignment & AlignHCenter != 0 ? hCenter.position
			- width * 0.5 : left.position
			+ left.padding;

	function alignLineY(height:Float)
		return alignment & AlignBottom != 0 ? bottom.position - bottom.padding - height : alignment & AlignVCenter != 0 ? vCenter.position
			- height * 0.5 : top.position
			+ top.padding;

	inline function setDisplayChar(index:Int, char:FontChar)
		if (index == chars.length)
			chars.push(char);
		else
			chars[index] = char;

	inline function trimDisplayChars(length:Int)
		if (chars.length != length)
			chars.resize(length);

	function rebuildLineChars() {
		lineWidth = 0.0;
		for (i in 0...text.length) {
			final c = font.copyFontChar(text.fastCodeAt(i), i < lineChars.length ? lineChars[i] : null);
			if (i == lineChars.length)
				lineChars.push(c);
			else
				lineChars[i] = c;
			lineWidth += c.advance;
		}
		if (lineChars.length != text.length)
			lineChars.resize(text.length);
	}

	function updateEllipsisChars():Float {
		var width = 0.0;
		for (i in 0...3) {
			final c = font.copyFontChar(".".code, i < ellipsisChars.length ? ellipsisChars[i] : null);
			setOrPush(ellipsisChars, i, c);
			width += c.advance;
		}
		return width;
	}

	inline function setOrPush<T>(items:Array<T>, index:Int, value:T)
		if (index == items.length)
			items.push(value);
		else
			items[index] = value;

	inline function copyLineRange(from:Int, to:Int, outIndex:Int):Int {
		for (i in from...to)
			setDisplayChar(outIndex++, lineChars[i]);
		return outIndex;
	}

	inline function copyEllipsis(outIndex:Int):Int {
		for (i in 0...3)
			setDisplayChar(outIndex++, ellipsisChars[i]);
		return outIndex;
	}

	function elideLineChars():Float {
		final availableWidth = Math.max(0.0, Math.abs(width) - left.padding - right.padding);

		if (elideMode == ElideNone || lineWidth <= availableWidth) {
			trimDisplayChars(lineChars.length);
			for (i in 0...lineChars.length)
				chars[i] = lineChars[i];
			return lineWidth;
		}

		final ew = updateEllipsisChars();
		final maxWidth = Math.max(0.0, availableWidth - ew);

		var w = 0.0;
		var e = false;
		var outIndex = 0;
		if (elideMode == ElideLeft) {
			var keepStart = lineChars.length;
			while (keepStart > 0) {
				final c = lineChars[keepStart - 1];
				if (w + c.advance > maxWidth) {
					e = true;
					break;
				}
				w += c.advance;
				keepStart--;
			}

			if (e)
				outIndex = copyEllipsis(outIndex);
			outIndex = copyLineRange(keepStart, lineChars.length, outIndex);
			if (e)
				w += ew;
		} else if (elideMode == ElideMiddle) {
			var leftIndex = 0;
			var rightIndex = lineChars.length - 1;
			var rightCount = 0;
			while (leftIndex <= rightIndex) {
				final leftChar = lineChars[leftIndex];
				if (w + leftChar.advance > maxWidth) {
					e = true;
					break;
				}
				w += leftChar.advance;
				leftIndex++;

				if (leftIndex > rightIndex)
					break;

				final rightChar = lineChars[rightIndex];
				if (w + rightChar.advance > maxWidth) {
					e = true;
					break;
				}
				w += rightChar.advance;
				rightIndex--;
				rightCount++;
			}

			outIndex = copyLineRange(0, leftIndex, outIndex);
			if (e) {
				outIndex = copyEllipsis(outIndex);
				w += ew;
			}
			outIndex = copyLineRange(lineChars.length - rightCount, lineChars.length, outIndex);
		} else if (elideMode == ElideRight) {
			var keepEnd = 0;
			while (keepEnd < lineChars.length) {
				final c = lineChars[keepEnd];
				if (w + c.advance > maxWidth) {
					e = true;
					break;
				}
				w += c.advance;
				keepEnd++;
			}

			outIndex = copyLineRange(0, keepEnd, outIndex);
			if (e) {
				outIndex = copyEllipsis(outIndex);
				w += ew;
			}
		} else {
			outIndex = copyLineRange(0, lineChars.length, outIndex);
			w = lineWidth;
		}

		trimDisplayChars(outIndex);
		return w;
	}
}
