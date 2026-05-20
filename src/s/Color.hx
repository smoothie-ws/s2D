package s;

import s.math.Vec3;
import s.math.Vec4;

/**
 * Creates a random opaque color.
 *
 * Each RGB channel is chosen independently in the `0.0..1.0` range.
 *
 * @return A random color with alpha set to `1.0`.
 */
extern inline function random():Color
	return rgba(Math.random(), Math.random(), Math.random());

/**
 * Linearly interpolates between two colors.
 *
 * Interpolation is performed on normalized RGBA channels.
 *
 * @param a Start color.
 * @param b End color.
 * @param t Interpolation factor in the `0.0..1.0` range.
 * @return The interpolated color.
 */
overload extern inline function mix(a:Color, b:Color, t:Float):Color
	return s.math.SMath.mix(a.RGBA, b.RGBA, t);

/**
 * Linearly interpolates between two colors using an 8-bit interpolation factor.
 *
 * `0` returns `a`, `255` returns `b`.
 *
 * @param a Start color.
 * @param b End color.
 * @param t Interpolation factor in the `0..255` range.
 * @return The interpolated color.
 */
overload extern inline function mix(a:Color, b:Color, t:Int):Color
	return mix(a, b, t / 255);

/**
 * Creates an opaque color from 8-bit RGB components.
 *
 * @param r Red channel in the `0..255` range.
 * @param g Green channel in the `0..255` range.
 * @param b Blue channel in the `0..255` range.
 * @return A color with alpha set to `255`.
 */
overload extern inline function rgb(r:Int, g:Int, b:Int):Color
	return rgb(r / 255, g / 255, b / 255);

/**
 * Creates an opaque color from normalized RGB components.
 *
 * @param r Red channel in the `0.0..1.0` range.
 * @param g Green channel in the `0.0..1.0` range.
 * @param b Blue channel in the `0.0..1.0` range.
 * @return A color with alpha set to `1.0`.
 */
overload extern inline function rgb(r:Float, g:Float, b:Float):Color
	return rgba(r, g, b);

/**
 * Creates a color from 8-bit RGBA components.
 *
 * @param r Red channel in the `0..255` range.
 * @param g Green channel in the `0..255` range.
 * @param b Blue channel in the `0..255` range.
 * @param a Alpha channel in the `0..255` range.
 * @return The resulting color.
 */
overload extern inline function rgba(r:Int, g:Int, b:Int, a:Int = 255):Color
	return rgba(r / 255, g / 255, b / 255, a / 255);

/**
 * Creates a color from 8-bit RGB components and a normalized alpha value.
 *
 * @param r Red channel in the `0..255` range.
 * @param g Green channel in the `0..255` range.
 * @param b Blue channel in the `0..255` range.
 * @param a Alpha channel in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function rgba(r:Int, g:Int, b:Int, a:Float = 1.0):Color
	return rgba(r / 255, g / 255, b / 255, a);

/**
 * Creates a color from normalized RGBA components.
 *
 * @param r Red channel in the `0.0..1.0` range.
 * @param g Green channel in the `0.0..1.0` range.
 * @param b Blue channel in the `0.0..1.0` range.
 * @param a Alpha channel in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function rgba(r:Float, g:Float, b:Float, a:Float = 1.0):Color
	return (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);

/**
 * Creates a color from normalized HSV components.
 *
 * @param h Hue in the `0.0..1.0` range.
 * @param s Saturation in the `0.0..1.0` range.
 * @param v Value in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function hsv(h:Float, s:Float, v:Float):Color
	return hsv2rgb(rgb(h, s, v));

/**
 * Creates a color from HSV components using common degree and percent ranges.
 *
 * @param h Hue in degrees, usually `0..360`.
 * @param s Saturation in percent, usually `0..100`.
 * @param v Value in percent, usually `0..100`.
 * @return The resulting color.
 */
overload extern inline function hsv(h:Int, s:Int, v:Int):Color
	return hsv(h / 360, s / 100, v / 100);

/**
 * Creates a color from HSV components and a normalized alpha value.
 *
 * @param h Hue in degrees, usually `0..360`.
 * @param s Saturation in percent, usually `0..100`.
 * @param v Value in percent, usually `0..100`.
 * @param a Alpha channel in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function hsva(h:Int, s:Int, v:Int, a:Float = 1.0):Color
	return hsva(h / 360, s / 100, v / 100, a);

/**
 * Creates a color from HSV components and an 8-bit alpha value.
 *
 * @param h Hue in degrees, usually `0..360`.
 * @param s Saturation in percent, usually `0..100`.
 * @param v Value in percent, usually `0..100`.
 * @param a Alpha channel in the `0..255` range.
 * @return The resulting color.
 */
overload extern inline function hsva(h:Int, s:Int, v:Int, a:Int = 255):Color
	return hsva(h / 360, s / 100, v / 100, a / 255);

/**
 * Creates a color from normalized HSVA components.
 *
 * @param h Hue in the `0.0..1.0` range.
 * @param s Saturation in the `0.0..1.0` range.
 * @param v Value in the `0.0..1.0` range.
 * @param a Alpha channel in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function hsva(h:Float, s:Float, v:Float, a:Float = 1.0):Color
	return hsv2rgb(rgba(h, s, v, a));

/**
 * Creates a color from normalized HSL components.
 *
 * @param h Hue in the `0.0..1.0` range.
 * @param s Saturation in the `0.0..1.0` range.
 * @param l Lightness in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function hsl(h:Float, s:Float, l:Float):Color
	return hsl2rgb(rgb(h, s, l));

/**
 * Creates a color from HSL components and an 8-bit alpha value.
 *
 * @param h Hue in degrees, usually `0..360`.
 * @param s Saturation in percent, usually `0..100`.
 * @param l Lightness in percent, usually `0..100`.
 * @param a Alpha channel in the `0..255` range.
 * @return The resulting color.
 */
overload extern inline function hsla(h:Int, s:Int, l:Int, a:Int = 255):Color
	return hsla(h / 360, s / 100, l / 100, a / 255);

/**
 * Creates a color from HSL components and a normalized alpha value.
 *
 * @param h Hue in degrees, usually `0..360`.
 * @param s Saturation in percent, usually `0..100`.
 * @param l Lightness in percent, usually `0..100`.
 * @param a Alpha channel in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function hsla(h:Int, s:Int, l:Int, a:Float = 1.0):Color
	return hsla(s / 360, h / 100, l / 100, a);

/**
 * Creates a color from normalized HSLA components.
 *
 * @param h Hue in the `0.0..1.0` range.
 * @param s Saturation in the `0.0..1.0` range.
 * @param l Lightness in the `0.0..1.0` range.
 * @param a Alpha channel in the `0.0..1.0` range.
 * @return The resulting color.
 */
overload extern inline function hsla(h:Float, s:Float, l:Float, a:Float = 1.0):Color
	return hsl2rgb(rgba(h, s, l, a));

/**
 * Converts a hue value into a fully saturated RGB color.
 *
 * @param hue Hue in the `0.0..1.0` range.
 * @return The RGB color for that hue.
 */
extern inline function hue2rgb(hue:Float):Color
	return s.math.SMath.clamp(s.math.SMath.abs(hue * 6.0 - s.math.SMath.vec3(3, 2, 4)) * s.math.SMath.vec3(1, -1, -1) + s.math.SMath.vec3(-1, 2, 2), 0.0, 1.0);

/**
 * Converts an RGB color to an HCV representation.
 *
 * The returned vector is stored as `(hue, chroma, value)`.
 *
 * @param color Source RGB color.
 * @return The converted HCV value.
 */
extern inline function rgb2hcv(color:Color):Color {
	var rgb:Vec3 = color;
	var p = (rgb.g < rgb.b) ? s.math.SMath.vec4(rgb.bg, -1.0, 2.0 / 3.0) : s.math.SMath.vec4(rgb.gb, 0.0, -1.0 / 3.0);
	var q = (rgb.r < p.x) ? s.math.SMath.vec4(p.xyw, rgb.r) : s.math.SMath.vec4(rgb.r, p.yzx);
	var c = q.x - s.math.SMath.min(q.w, q.y);
	var h = s.math.SMath.abs((q.w - q.y) / (6.0 * c + 1e-10) + q.z);
	return s.math.SMath.vec3(h, c, q.x);
}

/**
 * Converts an HSV color to RGB.
 *
 * @param color Source HSV color.
 * @return The converted RGB color.
 */
extern inline function hsv2rgb(color:Color):Color {
	var hsv:Vec3 = color;
	var rgb:Vec3 = hue2rgb(hsv.x);
	return ((rgb - 1.0) * hsv.y + 1.0) * hsv.z;
}

/**
 * Converts an HSL color to RGB.
 *
 * @param color Source HSL color.
 * @return The converted RGB color.
 */
extern inline function hsl2rgb(color:Color):Color {
	var hsl:Vec3 = color;
	var rgb:Vec3 = hue2rgb(hsl.x);
	var c = (1.0 - s.math.SMath.abs(2.0 * hsl.z - 1.0)) * hsl.y;
	return (rgb - 0.5) * c + hsl.z;
}

/**
 * Converts an RGB color to HSV.
 *
 * @param color Source RGB color.
 * @return The converted HSV color.
 */
extern inline function rgb2hsv(color:Color):Color {
	var hcv:Vec3 = rgb2hcv(color);
	var sat = hcv.y / (hcv.z + 1e-10);
	return s.math.SMath.vec3(hcv.x, sat, hcv.z);
}

/**
 * Converts an RGB color to HSL.
 *
 * @param rgb Source RGB color.
 * @return The converted HSL color.
 */
extern inline function rgb2hsl(rgb:Color):Color {
	var hcv:Vec3 = rgb2hcv(rgb);
	var z = hcv.z - hcv.y * 0.5;
	var sat = hcv.y / (1.0 - s.math.SMath.abs(z * 2.0 - 1.0) + 1e-10);
	return s.math.SMath.vec3(hcv.x, sat, z);
}

/**
 * Converts an sRGB color to linear RGB.
 *
 * @param srgb Source color in sRGB space.
 * @return The converted linear RGB color.
 */
extern inline function srgb2rgb(srgb:Color):Color
	return s.math.SMath.pow(srgb, s.math.SMath.vec3(2.1632601288));

/**
 * Converts a linear RGB color to sRGB.
 *
 * @param rgb Source color in linear RGB space.
 * @return The converted sRGB color.
 */
extern inline function rgb2srgb(rgb:Color):Color
	return s.math.SMath.pow(rgb, s.math.SMath.vec3(0.46226525728));

/**
 * Packed 32-bit color value with convenience accessors for RGB, HSV, and HSL channels.
 *
 * `Color` stores channels in `0xAARRGGBB` order and exposes normalized floating-point
 * component accessors in the `0.0..1.0` range unless noted otherwise.
 *
 * It is designed to be pleasant to use in gameplay, rendering, UI, and animation
 * code. You can treat it as:
 * - a packed integer color
 * - a set of normalized component properties
 * - a small conversion hub between RGB, HSV, HSL, vectors, strings, and `kha.Color`
 *
 * Typical usage:
 * ```haxe
 * var c = Color.fromString("#ff8844");
 * c.a = 0.5;
 * c.h += 0.1;
 * ```
 *
 * This abstract can be converted from and to `Int`, `String`, `kha.Color`, [`Vec3`](s.math.Vec3),
 * and [`Vec4`](s.math.Vec4).
 *
 * @see https://en.wikipedia.org/wiki/RGBA_color_model
 * @see https://en.wikipedia.org/wiki/HSL_and_HSV
 */
@:forward.new
extern enum abstract Color(Int) from Int to Int {
	/** Fully opaque black. */
	final Black = 0xff000000;

	/** Fully opaque white. */
	final White = 0xffffffff;

	/** Fully opaque red. */
	final Red = 0xffff0000;

	/** Fully opaque blue. */
	final Blue = 0xff0000ff;

	/** Fully opaque green. */
	final Green = 0xff00ff00;

	/** Fully opaque magenta. */
	final Magenta = 0xffff00ff;

	/** Fully opaque yellow. */
	final Yellow = 0xffffff00;

	/** Fully opaque cyan. */
	final Cyan = 0xff00ffff;

	/** Fully opaque purple. */
	final Purple = 0xff800080;

	/** Fully opaque pink. */
	final Pink = 0xffffc0cb;

	/** Fully opaque orange. */
	final Orange = 0xffffa500;

	/** Fully transparent black. */
	final Transparent = 0x00000000;

	/**
	 * Converts a `kha.Color` to `Color`.
	 *
	 * @param value Source `kha.Color`.
	 * @return The converted color.
	 */
	@:from
	public static inline function fromKhaColor(value:kha.Color):Color
		return value.value;

	/**
	 * Parses a color from a name or hexadecimal string.
	 *
	 * Supported names include `black`, `white`, `red`, `blue`, `green`, `magenta`,
	 * `yellow`, `cyan`, `purple`, `pink`, `orange`, and `transparent`.
	 *
	 * Supported hexadecimal formats are `#rgb`, `#rrggbb`, and `#aarrggbb`.
	 *
	 * @param value Color name or hexadecimal literal.
	 * @return The parsed color.
	 * @throws String If the string cannot be parsed as a color.
	 */
	@:from
	public static inline function fromString(value:String):Color
		return switch (value.toLowerCase()) {
			case "black":
				Color.Black;
			case "white":
				Color.White;
			case "red":
				Color.Red;
			case "blue":
				Color.Blue;
			case "green":
				Color.Green;
			case "magenta":
				Color.Magenta;
			case "yellow":
				Color.Yellow;
			case "cyan":
				Color.Cyan;
			case "purple":
				Color.Purple;
			case "pink":
				Color.Pink;
			case "orange":
				Color.Orange;
			case "transparent":
				Color.Transparent;
			default:
				if (!(value.length == 4 || value.length == 7 || value.length == 9) || StringTools.fastCodeAt(value, 0) != "#".code)
					throw 'Invalid Color string: $value';
				if (value.length == 4) {
					final r = value.charAt(1);
					final g = value.charAt(2);
					final b = value.charAt(3);
					value = '#$r$r$g$g$b$b';
				}
				var colorValue = Std.parseInt("0x" + value.substr(1));
				if (value.length == 7)
					colorValue += 0xFF000000;
				return colorValue | 0;
		}

	/** Red channel in the `0.0..1.0` range. */
	public var r(get, set):Float;

	/** Green channel in the `0.0..1.0` range. */
	public var g(get, set):Float;

	/** Blue channel in the `0.0..1.0` range. */
	public var b(get, set):Float;

	/** Alpha channel in the `0.0..1.0` range. */
	public var a(get, set):Float;

	/** Red channel byte. */
	public var rByte(get, set):Int;

	/** Green channel byte. */
	public var gByte(get, set):Int;

	/** Blue channel byte. */
	public var bByte(get, set):Int;

	/** Alpha channel byte. */
	public var aByte(get, set):Int;

	/**
	 * Hue component in the `0.0..1.0` range.
	 *
	 * `0.0` and `1.0` represent the same hue.
	 */
	public var h(get, set):Float;

	/** Saturation component in the `0.0..1.0` range of the HSV color model. */
	public var s(get, set):Float;

	/** Value component in the `0.0..1.0` range of the HSV color model. */
	public var v(get, set):Float;

	/** RGB channels as a normalized `Vec3` in `(r, g, b)` order. */
	public var RGB(get, set):Vec3;

	/** RGBA channels as a normalized `Vec4` in `(r, g, b, a)` order. */
	public var RGBA(get, set):Vec4;

	/** HSV channels as a normalized `Vec3` in `(h, s, v)` order. */
	public var HSV(get, set):Vec3;

	/** HSVA channels as a normalized `Vec4` in `(h, s, v, a)` order. */
	public var HSVA(get, set):Vec4;

	/** HSL channels as a normalized `Vec3` in `(h, s, l)` order. */
	public var HSL(get, set):Vec3;

	/** HSLA channels as a normalized `Vec4` in `(h, s, l, a)` order. */
	public var HSLA(get, set):Vec4;

	inline function new(value:Int)
		this = value;

	/**
	 * Converts this value to `kha.Color`.
	 *
	 * @return The same color as a `kha.Color`.
	 */
	@:to
	public inline function toColor():kha.Color
		return this;

	/**
	 * Converts this color to an 8-digit hexadecimal string.
	 *
	 * The returned format is `#AARRGGBB`.
	 *
	 * @return The hexadecimal color string.
	 */
	@:to
	public inline function toString():String
		return '#${StringTools.hex(this, 8)}';

	/**
	 * Creates a color from a normalized RGB vector.
	 *
	 * @param value RGB channels in `(r, g, b)` order.
	 * @return The resulting color.
	 */
	@:from
	public static inline function fromVec3(value:Vec3):Color
		return rgb(value.r, value.g, value.b);

	/**
	 * Creates a color from a normalized RGBA vector.
	 *
	 * @param value RGBA channels in `(r, g, b, a)` order.
	 * @return The resulting color.
	 */
	@:from
	public static inline function fromVec4(value:Vec4):Color
		return rgba(value.r, value.g, value.b, value.a);

	/**
	 * Converts this color to a normalized RGB vector.
	 *
	 * @return A `Vec3` in `(r, g, b)` order.
	 */
	@:to
	public inline function toVec3():Vec3
		return new Vec3(r, g, b);

	/**
	 * Converts this color to a normalized RGBA vector.
	 *
	 * @return A `Vec4` in `(r, g, b, a)` order.
	 */
	@:to
	public inline function toVec4():Vec4
		return new Vec4(r, g, b, a);

	private inline function get_rByte():Int
		return (this & 0x00ff0000) >>> 16;

	private inline function set_rByte(value:Int):Int {
		this = (this & 0xff00ffff) | (value << 16);
		return value;
	}

	private inline function get_gByte():Int
		return (this & 0x0000ff00) >>> 8;

	private inline function set_gByte(value:Int):Int {
		this = (this & 0xffff00ff) | (value << 8);
		return value;
	}

	private inline function get_bByte():Int
		return this & 0x000000ff;

	private inline function set_bByte(value:Int):Int {
		this = (this & 0xffffff00) | value;
		return value;
	}

	private inline function get_aByte():Int
		return this >>> 24;

	private inline function set_aByte(value:Int):Int {
		this = (this & 0x00ffffff) | (value << 24);
		return value;
	}

	private inline function get_r():Float
		return rByte / 255;

	private inline function set_r(value:Float):Float {
		rByte = (Std.int(value * 255));
		return value;
	}

	private inline function get_g():Float
		return gByte / 255;

	private inline function set_g(value:Float):Float {
		gByte = (Std.int(value * 255));
		return value;
	}

	private inline function get_b():Float
		return bByte / 255;

	private inline function set_b(value:Float):Float {
		bByte = (Std.int(value * 255));
		return value;
	}

	private inline function get_a():Float
		return aByte / 255;

	private inline function set_a(value:Float):Float {
		aByte = (Std.int(value * 255));
		return value;
	}

	private inline function get_h():Float
		return rgb2hsv(this).r;

	private inline function set_h(value:Float):Float {
		var c = hsv2rgb(new Vec3(value, s, v));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	private inline function get_s():Float
		return rgb2hsv(this).g;

	private inline function set_s(value:Float):Float {
		var c = hsv2rgb(new Vec3(h, value, v));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	private inline function get_v():Float
		return rgb2hsv(this).b;

	private inline function set_v(value:Float):Float {
		var c = hsv2rgb(new Vec3(h, s, value));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	private inline function get_RGB():Vec3
		return toVec3();

	private inline function set_RGB(value:Vec3):Vec3 {
		fromVec3(value);
		return value;
	}

	private inline function get_RGBA():Vec4
		return toVec4();

	private inline function set_RGBA(value:Vec4):Vec4 {
		fromVec4(value);
		return value;
	}

	private inline function get_HSV():Vec3
		return rgb2hsv(toVec3());

	private inline function set_HSV(value:Vec3):Vec3 {
		fromVec3(hsv2rgb(value));
		return value;
	}

	private inline function get_HSVA():Vec4
		return rgb2hsv(toVec3());

	private inline function set_HSVA(value:Vec4):Vec4 {
		fromVec4(hsv2rgb(value));
		return value;
	}

	private inline function get_HSL():Vec3
		return rgb2hsv(toVec3());

	private inline function set_HSL(value:Vec3):Vec3 {
		fromVec3(hsl2rgb(value));
		return value;
	}

	private inline function get_HSLA():Vec4
		return rgb2hsl(toVec3());

	private inline function set_HSLA(value:Vec4):Vec4 {
		fromVec4(hsl2rgb(value));
		return value;
	}
}
