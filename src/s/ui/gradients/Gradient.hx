package s.ui.gradients;

import haxe.io.Bytes;
import s.math.Vec2;
import s.math.Interpolation;
import s.assets.Image;

@:allow(s.ui.GradientStops)
@:allow(s.ui.graphics.gradients.GradientDrawer)
abstract class Gradient extends s.ui.elements.Drawable {
	var texture:Image;

	@:attr public var start:Vec2 = new Vec2(0.5, 0.0);
	@:attr public var end:Vec2 = new Vec2(0.5, 1.0);
	@:attr public var dither:Bool = false;
	@:attr.attached public var stops(default, set):GradientStops;
	@:attr(gradient) @:clamp(1) public var resolution:Int = 256;
	@:attr(gradient) public var interpolation:Interpolation = Interpolation.Linear;

	public function new(?stops:GradientStops) {
		super();
		texture = createTexture(Bytes.alloc(resolution * 4));
		@:bypassAccessor this.stops = new GradientStops([], this);

		if (stops != null)
			this.stops = stops;
	}

	override function update() {
		super.update();

		if (gradientDirty || resolutionDirty)
			updateGradient();
	}

	function updateGradient() {
		final pixels = Bytes.alloc(resolution * 4);
		final reverse = #if cpp true #else kha.Image.renderTargetsInvertedY() #end;

		inline function setGradientPixel(x:Int, color:Color)
			writePixel(pixels, reverse ? x : resolution - 1 - x, color);

		if (stops == null || stops.count == 0)
			for (i in 0...resolution)
				setGradientPixel(i, Transparent);
		else if (stops.count == 1) {
			var c = stops[0].color;
			for (i in 0...resolution)
				setGradientPixel(i, c);
		} else {
			var last = stops.count - 1;
			var j = 0;
			for (i in 0...resolution) {
				var p = resolution > 1 ? i / (resolution - 1) : 0.0;
				var c:Color;

				if (p <= stops[0].position)
					c = stops[0].color;
				else if (p >= stops[last].position)
					c = stops[last].color;
				else {
					while (j + 1 < stops.count && p > stops[j + 1].position)
						j++;

					var stop = stops[j];
					var next = stops[j + 1];
					var length = next.position - stop.position;
					var t = length == 0 ? 1.0 : (p - stop.position) / length;
					c = s.Color.mix(stop.color, next.color, interpolation(t));
				}

				setGradientPixel(i, c);
			}
		}

		texture.unload();
		texture = createTexture(pixels);
	}

	function set_stops(value:GradientStops)
		return stops = new GradientStops(value != null ? value.stops : [], this);

	inline function writePixel(pixels:Bytes, x:Int, color:Color) {
		final offset = x * 4;
		final value:Int = color;
		pixels.set(offset + 0, (value >>> 16) & 0xff);
		pixels.set(offset + 1, (value >>> 8) & 0xff);
		pixels.set(offset + 2, value & 0xff);
		pixels.set(offset + 3, (value >>> 24) & 0xff);
	}

	function createTexture(pixels:Bytes):Image
		return Image.fromBytes(pixels, resolution, 1);
}
