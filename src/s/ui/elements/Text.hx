package s.ui.elements;

import s.graphics.RenderTarget;
import s.ui.Alignment;

class Text extends Label {
	// @:attr var lines:Array<TextLine> = [];
	// @:attr public var wrapMode:WrapMode = NoWrap;
	// @:attr public var lineHeight:Float = 1.0;
	// @:attr public var lineHeightMode:LineHeightMode = Proportional;
	// @:attr public var maxLineCount:Int = -1;
	// @:readonly @:alias var lineCount:Int = lines.length;
	public function new(text:String = "") {
		super(text);
	}

	override function draw(target:RenderTarget) {
		// if (text.length == 0 || !font.isLoaded || font.size == 0)
		// 	return;
		// final ctx = target.context2D;
		// ctx.style.font. = font;
		// ctx.style.font.size = font.size;
		// ctx.style.color = color;
		// for (line in lines)
		// 	ctx.drawString(line.text, line.x, line.y);
	}

	// override function updateText() {
	// 	if (!font.isLoaded)
	// 		return;
	// 	final contentLeft = left.position + left.padding;
	// 	final contentRight = right.position - right.padding;
	// 	final contentTop = top.position + top.padding;
	// 	final contentBottom = bottom.position - bottom.padding;
	// 	final contentHCenter = (contentLeft + contentRight) * 0.5;
	// 	final contentVCenter = (contentTop + contentBottom) * 0.5;
	// 	final hBoundsDirty = left.positionDirty || left.paddingDirty || right.positionDirty || right.paddingDirty;
	// 	final vBoundsDirty = top.positionDirty || top.paddingDirty || bottom.positionDirty || bottom.paddingDirty;
	// 	final elideRelayoutDirty = elideMode != ElideNone
	// 		&& (elideModeDirty || heightDirty || widthDirty || vBoundsDirty || fontSizeDirty || lineHeightDirty || lineHeightModeDirty);
	// 	if (textDirty
	// 		|| fontSizeDirty
	// 		|| maxLineCountDirty
	// 		|| wrapModeDirty
	// 		|| ((widthDirty || hBoundsDirty) && wrapMode != NoWrap)
	// 		|| elideRelayoutDirty)
	// 		wrapText();
	// 	if (elideMode != ElideNone && (linesDirty || elideRelayoutDirty))
	// 		elideText();
	// 	if (linesDirty || fontSizeDirty) {
	// 		textWidth = Math.NEGATIVE_INFINITY;
	// 		textX = Math.POSITIVE_INFINITY;
	// 		if ((alignment & AlignHCenter) != 0)
	// 			for (l in lines) {
	// 				l.x = contentHCenter - l.width * 0.5;
	// 				textWidth = Math.max(textWidth, l.width);
	// 				textX = Math.min(textX, l.x);
	// 			}
	// 		else if ((alignment & AlignRight) != 0)
	// 			for (l in lines) {
	// 				l.x = contentRight - l.width;
	// 				textWidth = Math.max(textWidth, l.width);
	// 				textX = Math.min(textX, l.x);
	// 			}
	// 		else
	// 			for (l in lines) {
	// 				l.x = contentLeft;
	// 				textWidth = Math.max(textWidth, l.width);
	// 				textX = Math.min(textX, l.x);
	// 			}
	// 	} else {
	// 		if ((alignmentDirty || hBoundsDirty) && (alignment & AlignHCenter) != 0)
	// 			for (l in lines)
	// 				l.x = contentHCenter - l.width * 0.5;
	// 		else if ((alignmentDirty || hBoundsDirty) && (alignment & AlignRight) != 0)
	// 			for (l in lines)
	// 				l.x = contentRight - l.width;
	// 		else if (alignmentDirty || hBoundsDirty)
	// 			for (l in lines)
	// 				l.x = contentLeft;
	// 	}
	// 	if (linesDirty || fontSizeDirty || lineHeightDirty || lineHeightModeDirty) {
	// 		var realLineHeight = switch lineHeightMode {
	// 			case Proportional: font.size * lineHeight;
	// 			case Fixed: lineHeight;
	// 		}
	// 		for (l in lines)
	// 			l.height = realLineHeight;
	// 		textHeight = lineCount * realLineHeight;
	// 	}
	// 	var vDirty = alignmentDirty || textHeightDirty || vBoundsDirty;
	// 	if (vDirty && (alignment & AlignVCenter) != 0)
	// 		textY = contentVCenter - textHeight * 0.5;
	// 	else if (vDirty && (alignment & AlignBottom) != 0)
	// 		textY = contentBottom - textHeight;
	// 	else if (vDirty)
	// 		textY = contentTop;
	// 	if (linesDirty || textYDirty) {
	// 		for (i in 0...lineCount)
	// 			lines[i].y = textY + lines[i].height * i;
	// 		if (linesDirty) {
	// 			var buf = new StringBuf();
	// 			for (i in 0...lines.length) {
	// 				buf.add(lines[i].text);
	// 				if (i < lines.length - 1)
	// 					buf.add("\n");
	// 			}
	// 			displayText = buf.toString();
	// 		}
	// 	}
	// }
	// function wrapText() {
	// 	var k = font.asset._get(font.size);
	// 	var maxWidth = Math.max(0.0, Math.abs(width) - left.padding - right.padding);
	// 	lines = [];
	// 	inline function isNewline(c:Int):Bool
	// 		return c == "\n".code || c == "\r".code || c == 0x85 || c == 0x2028 || c == 0x2029;
	// 	inline function isSpace(c:Int):Bool
	// 		return switch c {
	// 			case "\t".code, 0x0B, 0x0C, " ".code, 0xA0, 0x1680, 0x202F, 0x205F, 0x3000: true;
	// 			case _ if (0x2000 <= c && c <= 0x200A): true;
	// 			case _: false;
	// 		}
	// 	inline function charWidth(c:Int):Float
	// 		return @:privateAccess k.getCharWidth(c);
	// 	inline function maxReached():Bool
	// 		return maxLineCount >= 0 && lineCount >= maxLineCount;
	// 	inline function nextCharIndex(i:Int, c:Int):Int {
	// 		if (c == "\r".code && i + 1 < text.length && text.charCodeAt(i + 1) == "\n".code)
	// 			return i + 2;
	// 		return i + 1;
	// 	}
	// 	function pushLine(line:String, lineWidth:Float):Bool {
	// 		lines.push({text: line, width: lineWidth});
	// 		return maxReached();
	// 	}
	// 	function wrapWord(word:String, line:StringBuf, lineWidth:Float):{line:StringBuf, lineWidth:Float, stop:Bool} {
	// 		if (word.length == 0)
	// 			return {line: line, lineWidth: lineWidth, stop: false};
	// 		if (maxWidth <= 0) {
	// 			if (lineWidth > 0 && pushLine(line.toString(), lineWidth))
	// 				return {line: new StringBuf(), lineWidth: 0.0, stop: true};
	// 			if (pushLine(word, k.stringWidth(word)))
	// 				return {line: new StringBuf(), lineWidth: 0.0, stop: true};
	// 			return {line: new StringBuf(), lineWidth: 0.0, stop: false};
	// 		}
	// 		var current = line;
	// 		var currentWidth = lineWidth;
	// 		var i = 0;
	// 		while (i < word.length) {
	// 			if (currentWidth > 0) {
	// 				var c = word.charCodeAt(i);
	// 				var cw = charWidth(c);
	// 				if (currentWidth + cw > maxWidth) {
	// 					if (pushLine(current.toString(), currentWidth))
	// 						return {line: new StringBuf(), lineWidth: 0.0, stop: true};
	// 					current = new StringBuf();
	// 					currentWidth = 0.0;
	// 					continue;
	// 				}
	// 				current.addChar(c);
	// 				currentWidth += cw;
	// 				i++;
	// 				continue;
	// 			}
	// 			var part = new StringBuf();
	// 			var partWidth = 0.0;
	// 			while (i < word.length) {
	// 				var c = word.charCodeAt(i);
	// 				var cw = charWidth(c);
	// 				if (partWidth > 0 && partWidth + cw > maxWidth)
	// 					break;
	// 				part.addChar(c);
	// 				partWidth += cw;
	// 				i++;
	// 			}
	// 			if (partWidth == 0.0) {
	// 				var c = word.charCodeAt(i);
	// 				part.addChar(c);
	// 				partWidth = charWidth(c);
	// 				i++;
	// 			}
	// 			current.add(part.toString());
	// 			currentWidth = partWidth;
	// 			if (i < word.length) {
	// 				if (pushLine(current.toString(), currentWidth))
	// 					return {line: new StringBuf(), lineWidth: 0.0, stop: true};
	// 				current = new StringBuf();
	// 				currentWidth = 0.0;
	// 			}
	// 		}
	// 		return {line: current, lineWidth: currentWidth, stop: false};
	// 	}
	// 	switch wrapMode {
	// 		case NoWrap:
	// 			var line = new StringBuf();
	// 			var i = 0;
	// 			while (i < text.length) {
	// 				var c = text.charCodeAt(i);
	// 				if (isNewline(c)) {
	// 					var str = line.toString();
	// 					if (pushLine(str, k.stringWidth(str)))
	// 						return;
	// 					line = new StringBuf();
	// 					i = nextCharIndex(i, c);
	// 					continue;
	// 				}
	// 				line.addChar(c);
	// 				i++;
	// 			}
	// 			if (!maxReached()) {
	// 				var str = line.toString();
	// 				pushLine(str, k.stringWidth(str));
	// 			}
	// 		case WrapAnywhere:
	// 			var line = new StringBuf();
	// 			var lineWidth = 0.0;
	// 			var i = 0;
	// 			while (i < text.length) {
	// 				var c = text.charCodeAt(i);
	// 				if (isNewline(c)) {
	// 					if (pushLine(line.toString(), lineWidth))
	// 						return;
	// 					line = new StringBuf();
	// 					lineWidth = 0.0;
	// 					i = nextCharIndex(i, c);
	// 					continue;
	// 				}
	// 				var cw = charWidth(c);
	// 				if (lineWidth > 0 && maxWidth > 0 && lineWidth + cw > maxWidth) {
	// 					if (pushLine(line.toString(), lineWidth))
	// 						return;
	// 					line = new StringBuf();
	// 					lineWidth = 0.0;
	// 				}
	// 				line.addChar(c);
	// 				lineWidth += cw;
	// 				i++;
	// 			}
	// 			if (!maxReached())
	// 				pushLine(line.toString(), lineWidth);
	// 		case WordWrap, Wrap:
	// 			var line = new StringBuf();
	// 			var lineWidth = 0.0;
	// 			var word = new StringBuf();
	// 			var wordWidth = 0.0;
	// 			function flushWord():Bool {
	// 				if (word.length == 0)
	// 					return false;
	// 				var value = word.toString();
	// 				if (wrapMode == WordWrap || wordWidth <= maxWidth || maxWidth <= 0) {
	// 					if (lineWidth > 0 && maxWidth > 0 && lineWidth + wordWidth > maxWidth) {
	// 						if (pushLine(line.toString(), lineWidth))
	// 							return true;
	// 						line = new StringBuf();
	// 						lineWidth = 0.0;
	// 					}
	// 					line.add(value);
	// 					lineWidth += wordWidth;
	// 				} else {
	// 					var wrapped = wrapWord(value, line, lineWidth);
	// 					line = wrapped.line;
	// 					lineWidth = wrapped.lineWidth;
	// 					if (wrapped.stop)
	// 						return true;
	// 				}
	// 				word = new StringBuf();
	// 				wordWidth = 0.0;
	// 				return false;
	// 			}
	// 			var i = 0;
	// 			while (i < text.length) {
	// 				var c = text.charCodeAt(i);
	// 				if (isNewline(c)) {
	// 					if (flushWord())
	// 						return;
	// 					if (pushLine(line.toString(), lineWidth))
	// 						return;
	// 					line = new StringBuf();
	// 					lineWidth = 0.0;
	// 					i = nextCharIndex(i, c);
	// 					continue;
	// 				}
	// 				if (isSpace(c)) {
	// 					if (flushWord())
	// 						return;
	// 					var cw = charWidth(c);
	// 					if (lineWidth > 0) {
	// 						if (maxWidth > 0 && lineWidth + cw > maxWidth) {
	// 							if (pushLine(line.toString(), lineWidth))
	// 								return;
	// 							line = new StringBuf();
	// 							lineWidth = 0.0;
	// 						} else {
	// 							line.addChar(c);
	// 							lineWidth += cw;
	// 						}
	// 					}
	// 					i++;
	// 					continue;
	// 				}
	// 				word.addChar(c);
	// 				wordWidth += charWidth(c);
	// 				i++;
	// 			}
	// 			if (flushWord())
	// 				return;
	// 			if (!maxReached())
	// 				pushLine(line.toString(), lineWidth);
	// 	}
	// }
	// function elideText() {
	// 	if (lineCount == 0)
	// 		return;
	// 	final maxHeight = Math.max(0.0, Math.abs(height) - top.padding - bottom.padding);
	// 	final realLineHeight = switch lineHeightMode {
	// 		case Proportional: font.size * lineHeight;
	// 		case Fixed: lineHeight;
	// 	}
	// 	var visibleHeight = lineCount * realLineHeight;
	// 	var removedLines = false;
	// 	var changed = false;
	// 	if (elideMode == ElideLeft) {
	// 		while (lineCount > 1 && visibleHeight > maxHeight) {
	// 			lines.shift();
	// 			visibleHeight -= realLineHeight;
	// 			removedLines = true;
	// 			changed = true;
	// 		}
	// 		changed = elideLine(lines[0], removedLines) || changed;
	// 	} else if (elideMode == ElideMiddle) {
	// 		while (lineCount > 1 && visibleHeight > maxHeight) {
	// 			lines.shift();
	// 			visibleHeight -= realLineHeight;
	// 			removedLines = true;
	// 			changed = true;
	// 			if (lineCount > 1 && visibleHeight > maxHeight) {
	// 				lines.pop();
	// 				visibleHeight -= realLineHeight;
	// 				changed = true;
	// 			}
	// 		}
	// 		changed = elideLine(lines[Std.int(lineCount * 0.5)], removedLines) || changed;
	// 	} else if (elideMode == ElideRight) {
	// 		while (lineCount > 1 && visibleHeight > maxHeight) {
	// 			lines.pop();
	// 			visibleHeight -= realLineHeight;
	// 			removedLines = true;
	// 			changed = true;
	// 		}
	// 		changed = elideLine(lines[lineCount - 1], removedLines) || changed;
	// 	}
	// 	if (changed) {
	// 		linesDirty = true;
	// 		textHeight = visibleHeight;
	// 	}
	// }
}
