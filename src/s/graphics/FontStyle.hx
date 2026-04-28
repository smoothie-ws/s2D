package s.graphics;

import s.assets.Font;

typedef FontChar = {
	xoff:Float,
	yoff:Float,
	advance:Float,
	pos:{x:Float, y:Float, width:Float, height:Float},
	uv:{x:Float, y:Float, width:Float, height:Float}
}

enum abstract FontWeight(Int) from Int to Int {
	var Thin = 100;
	var ExtraLight = 200;
	var Light = 300;
	var Normal = 400;
	var Medium = 500;
	var DemiBold = 600;
	var Bold = 700;
	var ExtraBold = 800;
	var Black = 900;
}

enum FontCapitalization {
	MixedCase;
	AllUppercase;
	AllLowercase;
	SmallCaps;
	Capitalize;
}

@:allow(s.graphics.shaders.TextShader)
class FontStyle implements s.shortcut.Shortcut {
	var font:Font = "default";

	var italicSlant:Float = 0.0;
	var sdfWeight:Float = 0.0;

	public var family(default, set):String = "default";

	@:inject(setSdfWeight) public var bold:Bool = false;
	public var italic(default, set):Bool = false;
	public var strikeout:Bool = false; // TODO
	public var underline:Bool = false; // TODO
	public var snapToPixel:Bool = true;

	@:attr(spacing) public var wordSpacing:Float = 0.0;
	@:attr(spacing) public var letterSpacing:Float = 0.0;

	@:inject(setSdfWeight) public var weight:FontWeight = Normal;
	public var softness:Float = 0.0;
	public var outlineColor:Color = Transparent;
	public var outlineWidth:Float = 0.0;

	// public var backgroundColor:Color = Transparent; // TODO
	// public var capitalization:FontCapitalization; // TODO
	// public var pointSize(get, set):Float;
	@:attr(metrics) public var size(default, set):Int = 18;

	// public var preferShaping:Bool;
	// public var preferTypoLineMetrics:Bool;
	// public var styleName:String;
	// public var variableAxes:object;
	// public var contextFontMerging:Bool;
	// public var features:object;
	// public var hintingPreference:enumeration;
	// public var kerning:Bool;
	@:readonly @:alias public var isLoaded:Bool = font.isLoaded;

	public function new() {}

	public function copyFrom(value:FontStyle):FontStyle {
		if (value == null)
			return this;
		family = value.family;
		bold = value.bold;
		italic = value.italic;
		strikeout = value.strikeout;
		underline = value.underline;
		snapToPixel = value.snapToPixel;
		wordSpacing = value.wordSpacing;
		letterSpacing = value.letterSpacing;
		weight = value.weight;
		softness = value.softness;
		outlineColor = value.outlineColor;
		outlineWidth = value.outlineWidth;
		size = value.size;
		return this;
	}

	public function setDefault():FontStyle {
		family = "default";
		bold = false;
		italic = false;
		strikeout = false;
		underline = false;
		snapToPixel = true;
		wordSpacing = 0.0;
		letterSpacing = 0.0;
		weight = Normal;
		softness = 0.0;
		outlineColor = Transparent;
		outlineWidth = 0.0;
		size = 18;
		return this;
	}

	public inline function getAtlas()
		return font.getAtlas(size);

	inline function copyFontCharTemplate(template:s.assets.internal.font.Font.CachedFontCharTemplate, scale:Float, spacing:Float, out:FontChar):FontChar {
		if (out == null)
			return {
				xoff: template.xoff * scale,
				yoff: template.yoff * scale,
				advance: template.advance * scale + spacing,
				pos: {
					x: 0.0,
					y: 0.0,
					width: template.width * scale,
					height: template.height * scale
				},
				uv: {
					x: template.uvX,
					y: template.uvY,
					width: template.uvWidth,
					height: template.uvHeight
				}
			};

		out.xoff = template.xoff * scale;
		out.yoff = template.yoff * scale;
		out.advance = template.advance * scale + spacing;
		out.pos.width = template.width * scale;
		out.pos.height = template.height * scale;
		out.uv.x = template.uvX;
		out.uv.y = template.uvY;
		out.uv.width = template.uvWidth;
		out.uv.height = template.uvHeight;
		return out;
	}

	public inline function getFontCharFromAtlas(atlas:s.assets.internal.font.FontAtlas, scale:Float, char:Int):FontChar {
		return copyFontCharTemplate(font.getFontCharTemplate(atlas, char), scale, 0.0, null);
	}

	public function copyFontChar(char:Int, out:FontChar = null):FontChar {
		final atlas = getAtlas();
		final scale = size / atlas.size;
		return copyFontCharTemplate(font.getFontCharTemplate(atlas, char), scale, getSpacing(char), out);
	}

	public function getFontChar(char:Int):FontChar {
		return copyFontChar(char);
	}

	public function widthOfCharacters(chars:Array<Int>, start:Int, length:Int):Float {
		if (size <= 0 || chars == null || length <= 0)
			return 0.0;

		var atlas = getAtlas();
		var scale = size / atlas.size;
		var end = Std.int(Math.min(start + length, chars.length));

		var width = 0.0;
		for (i in start...end) {
			var char = chars[i];
			width += atlas.getGlyph(char).xadvance * scale;
			if (i < end - 1)
				width += getSpacing(char);
		}

		return width;
	}

	public function widthOfString(text:String, start:Int, length:Int):Float {
		if (size <= 0 || text == null || length <= 0)
			return 0.0;

		final atlas = getAtlas();
		final scale = size / atlas.size;
		final end = Std.int(Math.min(start + length, text.length));

		var width = 0.0;
		for (i in start...end)
			width += atlas.getGlyph(text.charCodeAt(i)).xadvance * scale;

		return width;
	}

	inline function getSpacing(char:Int) {
		var spacing = letterSpacing;
		if (char == " ".code || char == "\t".code)
			spacing += wordSpacing;
		return spacing;
	}

	inline function get_pointSize():Float
		return size * 72.0 / s.app.Display.primary.pixelsPerInch;

	inline function set_pointSize(value:Float):Float {
		size = Std.int(value * s.app.Display.primary.pixelsPerInch / 72.0);
		return value;
	}

	inline function set_family(value:String):String {
		if (value == null || value == "")
			value = "default";
		if (family == value)
			return family;

		font = value;
		return family = value;
	}

	inline function setSdfWeight()
		sdfWeight = ((weight : Int) - (FontWeight.Medium : Int)) / 400.0 * 0.5 + (bold ? 0.75 : 0.0);

	inline function set_italic(value:Bool) {
		italicSlant = value ? 0.21256 : 0.0;
		return italic = value;
	}

	inline function set_outlineWidth(value:Float)
		return outlineWidth = Math.max(0.0, value);

	inline function set_softness(value:Float)
		return softness = Math.max(0.0, value);

	inline function set_pixelSize(value:Int):Int
		return size = value > 0 ? value : 0;
}
