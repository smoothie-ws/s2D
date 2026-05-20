package s.assets.internal.font;

import haxe.ds.IntMap;
import haxe.ds.Vector;
import kha.Blob;
import kha.Kravur;
import kha.graphics2.truetype.StbTruetype;

private typedef GlyphPoint = {
	var x:Float;
	var y:Float;
}

private typedef GlyphSegment = {
	var ax:Float;
	var ay:Float;
	var bx:Float;
	var by:Float;
}

typedef CachedFontCharTemplate = {
	var xoff:Float;
	var yoff:Float;
	var advance:Float;
	var width:Float;
	var height:Float;
	var uvX:Float;
	var uvY:Float;
	var uvWidth:Float;
	var uvHeight:Float;
}

private class SdfScratch {
	public var capacity:Int = 0;
	public var spanCapacity:Int = 0;
	public var inside:Vector<Float>;
	public var outside:Vector<Float>;
	public var tmp:Vector<Float>;
	public var distInside:Vector<Float>;
	public var distOutside:Vector<Float>;
	public var f:Vector<Float>;
	public var d:Vector<Float>;
	public var v:Vector<Int>;
	public var z:Vector<Float>;

	public function new() {}

	public function ensure(count:Int, span:Int) {
		if (capacity < count) {
			capacity = count;
			inside = new Vector<Float>(capacity);
			outside = new Vector<Float>(capacity);
			tmp = new Vector<Float>(capacity);
			distInside = new Vector<Float>(capacity);
			distOutside = new Vector<Float>(capacity);
		}
		if (spanCapacity < span) {
			spanCapacity = span;
			f = new Vector<Float>(spanCapacity);
			d = new Vector<Float>(spanCapacity);
			v = new Vector<Int>(spanCapacity);
			z = new Vector<Float>(spanCapacity + 1);
		}
	}
}

class Font extends Asset<kha.Font> {
	public static inline final sdfOversample:Int = 2;
	public static inline final sdfSpread:Int = 8;
	public static inline final sdfPadding:Int = sdfSpread + 2;
	public static inline final sdfInf:Float = 1e20;
	public static inline final sdfQuadraticFlatnessSq:Float = 0.02;
	public static inline final sdfCubicFlatnessSq:Float = 0.02;
	public static inline final sdfFast:Bool = true;

	static final defaultGlyphs:Array<Int> = [for (i in 32...127) i];

	static function sanitizeGlyphs(glyphs:Array<Int>):Array<Int>
		return glyphs != null && glyphs.length > 0 ? glyphs : defaultGlyphs;

	static function glyphsEqual(a:Array<Int>, b:Array<Int>):Bool {
		if (a == b)
			return true;
		if (a == null || b == null || a.length != b.length)
			return false;
		for (i in 0...a.length)
			if (a[i] != b[i])
				return false;
		return true;
	}

	static function hashGlyphs(glyphs:Array<Int>):Int {
		var hash = 0x811C9DC5;
		for (glyph in glyphs) {
			hash = (hash ^ glyph) * 16777619;
			hash |= 0;
		}
		return hash;
	}

	static function rebuildCharBlocks(glyphs:Array<Int>) {
		KravurImage.charBlocks = [];
		if (glyphs.length == 0)
			return;

		KravurImage.charBlocks.push(glyphs[0]);
		var nextChar = glyphs[0] + 1;
		for (i in 1...glyphs.length) {
			if (glyphs[i] != nextChar) {
				KravurImage.charBlocks.push(glyphs[i - 1]);
				KravurImage.charBlocks.push(glyphs[i]);
				nextChar = glyphs[i] + 1;
			} else
				nextChar++;
		}
		KravurImage.charBlocks.push(glyphs[glyphs.length - 1]);
	}

	static function quantizeAtlasSize(size:Int):Int {
		if (size <= 24)
			return size;
		if (size <= 48)
			return Std.int(Math.ceil(size / 2.0)) * 2;
		if (size <= 64)
			return Std.int(Math.ceil(size / 2.0)) * 2;
		if (size <= 128)
			return Std.int(Math.ceil(size / 4.0)) * 4;
		if (size <= 256)
			return Std.int(Math.ceil(size / 8.0)) * 8;
		return Std.int(Math.ceil(size / 16.0)) * 16;
	}

	static inline function makeAtlasKey(fontIndex:Int, nominalSize:Int, glyphHash:Int):Int {
		var key = fontIndex;
		key = ((key * 397) ^ nominalSize) | 0;
		key = ((key * 397) ^ glyphHash) | 0;
		return key;
	}

	static inline function makeGlyphSegmentKey(fontIndex:Int, bakedFontSize:Int, glyphIndex:Int):Int {
		var key = fontIndex;
		key = ((key * 397) ^ bakedFontSize) | 0;
		key = ((key * 397) ^ glyphIndex) | 0;
		return key;
	}

	static function bakeFontBitmap(data:Blob, offset:Int, pixel_height:Float, pixels:Blob, pw:Int, ph:Int, chars:Array<Int>, chardata:Vector<Stbtt_bakedchar>,
			fontIndex:Int, bakedFontSize:Int, glyphSegments:IntMap<Array<GlyphSegment>>):Int @:privateAccess {
		var scale:Float;
		var x:Int, y:Int, bottom_y:Int;
		var f:Stbtt_fontinfo = new Stbtt_fontinfo();
		if (!StbTruetype.stbtt_InitFont(f, data, offset))
			return -1;
		x = y = 1;
		bottom_y = 1;

		scale = StbTruetype.stbtt_ScaleForPixelHeight(f, pixel_height);

		var i = 0;
		for (index in chars) {
			var advance:Int, lsb:Int, x0:Int, y0:Int, x1:Int, y1:Int, gw:Int, gh:Int;
			var g:Int = StbTruetype.stbtt_FindGlyphIndex(f, index);
			var metrics = StbTruetype.stbtt_GetGlyphHMetrics(f, g);
			advance = metrics.advanceWidth;
			lsb = metrics.leftSideBearing;
			var rect = StbTruetype.stbtt_GetGlyphBitmapBox(f, g, scale, scale);
			x0 = rect.x0;
			y0 = rect.y0;
			x1 = rect.x1;
			y1 = rect.y1;
			gw = x1 - x0;
			gh = y1 - y0;
			if (gw > 0 && gh > 0 && x + gw + sdfPadding * 2 + 1 >= pw) {
				y = bottom_y;
				x = 1; // advance to next row
			}
			if (gw > 0 && gh > 0 && y + gh + sdfPadding * 2 + 1 >= ph) // check if it fits vertically AFTER potentially moving to next row
				return -i;

			if (gw > 0 && gh > 0) {
				StbTruetype.STBTT_assert(x + gw + sdfPadding * 2 < pw);
				StbTruetype.STBTT_assert(y + gh + sdfPadding * 2 < ph);
				chardata[i].x0 = x;
				chardata[i].y0 = y;
				chardata[i].x1 = x + gw + sdfPadding * 2;
				chardata[i].y1 = y + gh + sdfPadding * 2;
				chardata[i].xoff = x0 - sdfPadding;
				chardata[i].yoff = y0 - sdfPadding;
				x = x + gw + sdfPadding * 2 + 1;
				if (y + gh + sdfPadding * 2 + 1 > bottom_y)
					bottom_y = y + gh + sdfPadding * 2 + 1;
			} else {
				chardata[i].x0 = x;
				chardata[i].y0 = y;
				chardata[i].x1 = x;
				chardata[i].y1 = y;
				chardata[i].xoff = x0;
				chardata[i].yoff = y0;
			}
			chardata[i].xadvance = scale * advance / sdfOversample;
			chardata[i].xoff /= sdfOversample;
			chardata[i].yoff /= sdfOversample;
			++i;
		}
		for (i in 0...pw * ph)
			pixels.writeU8(i, 0); // background of 0 around pixels
		i = 0;
		var ch:Stbtt_bakedchar;
		final scratch = new SdfScratch();
		for (index in chars) {
			var g:Int = StbTruetype.stbtt_FindGlyphIndex(f, index);
			ch = chardata[i];
			if (ch.x1 > ch.x0 && ch.y1 > ch.y0) {
				final glyphWidth = ch.x1 - ch.x0 - sdfPadding * 2;
				final glyphHeight = ch.y1 - ch.y0 - sdfPadding * 2;
				StbTruetype.stbtt_MakeGlyphBitmap(f, pixels, ch.x0 + sdfPadding + (ch.y0 + sdfPadding) * pw, glyphWidth, glyphHeight, pw, scale, scale, g);
				buildGlyphSdfFromBitmap(pixels, pw, ch, scratch);
			}
			++i;
		}
		return bottom_y;
	}

	static function estimateAtlasSize(data:Blob, offset:Int, pixelHeight:Float, chars:Array<Int>, padding:Int):{width:Int, height:Int} {
		var f:Stbtt_fontinfo = new Stbtt_fontinfo();
		if (!StbTruetype.stbtt_InitFont(f, data, offset))
			return {width: 64, height: 32};

		final scale = StbTruetype.stbtt_ScaleForPixelHeight(f, pixelHeight);
		var maxPackedWidth = 1;
		var maxPackedHeight = 1;
		var totalArea = 0.0;

		for (index in chars) {
			var g:Int = StbTruetype.stbtt_FindGlyphIndex(f, index);
			var rect = StbTruetype.stbtt_GetGlyphBitmapBox(f, g, scale, scale);
			var gw = rect.x1 - rect.x0;
			var gh = rect.y1 - rect.y0;
			if (gw > 0 && gh > 0) {
				var packedWidth = gw + padding * 2 + 1;
				var packedHeight = gh + padding * 2 + 1;
				if (packedWidth > maxPackedWidth)
					maxPackedWidth = packedWidth;
				if (packedHeight > maxPackedHeight)
					maxPackedHeight = packedHeight;
				totalArea += packedWidth * packedHeight;
			}
		}

		var width = nextPow2(Std.int(Math.max(64.0, Math.sqrt(Math.max(totalArea, 1.0)))));
		if (width < maxPackedWidth)
			width = nextPow2(maxPackedWidth);
		var height = nextPow2(Std.int(Math.max(32.0, totalArea / width)));
		if (height < maxPackedHeight)
			height = nextPow2(maxPackedHeight);

		while (!canPackAtlas(data, offset, pixelHeight, chars, width, height, padding)) {
			if (height < width)
				height *= 2;
			else
				width *= 2;
		}

		return {width: width, height: height};
	}

	static function canPackAtlas(data:Blob, offset:Int, pixelHeight:Float, chars:Array<Int>, pw:Int, ph:Int, padding:Int):Bool {
		var f:Stbtt_fontinfo = new Stbtt_fontinfo();
		if (!StbTruetype.stbtt_InitFont(f, data, offset))
			return false;

		final scale = StbTruetype.stbtt_ScaleForPixelHeight(f, pixelHeight);
		var x = 1;
		var y = 1;
		var bottom_y = 1;

		for (index in chars) {
			var g:Int = StbTruetype.stbtt_FindGlyphIndex(f, index);
			var rect = StbTruetype.stbtt_GetGlyphBitmapBox(f, g, scale, scale);
			var gw = rect.x1 - rect.x0;
			var gh = rect.y1 - rect.y0;
			if (gw > 0 && gh > 0 && x + gw + padding * 2 + 1 >= pw) {
				y = bottom_y;
				x = 1;
			}
			if (gw > 0 && gh > 0 && y + gh + padding * 2 + 1 >= ph)
				return false;
			if (gw > 0 && gh > 0) {
				x += gw + padding * 2 + 1;
				var glyphBottom = y + gh + padding * 2 + 1;
				if (glyphBottom > bottom_y)
					bottom_y = glyphBottom;
			}
		}

		return true;
	}

	static inline function nextPow2(value:Int):Int {
		var result = 1;
		while (result < value)
			result <<= 1;
		return result;
	}

	static inline function glyphPoint(x:Float, y:Float):GlyphPoint
		return {x: x, y: y};

	static inline function addGlyphSegment(segments:Array<GlyphSegment>, a:GlyphPoint, b:GlyphPoint) {
		if (a.x == b.x && a.y == b.y)
			return;
		segments.push({
			ax: a.x,
			ay: a.y,
			bx: b.x,
			by: b.y
		});
	}

	static inline function midpoint(a:GlyphPoint, b:GlyphPoint):GlyphPoint
		return glyphPoint((a.x + b.x) * 0.5, (a.y + b.y) * 0.5);

	static inline function pointLineDistanceSq(p:GlyphPoint, a:GlyphPoint, b:GlyphPoint):Float {
		final dx = b.x - a.x;
		final dy = b.y - a.y;
		final denom = dx * dx + dy * dy;
		if (denom <= 1e-8) {
			final px = p.x - a.x;
			final py = p.y - a.y;
			return px * px + py * py;
		}
		final t = Math.max(0.0, Math.min(1.0, ((p.x - a.x) * dx + (p.y - a.y) * dy) / denom));
		final qx = a.x + dx * t;
		final qy = a.y + dy * t;
		final ox = p.x - qx;
		final oy = p.y - qy;
		return ox * ox + oy * oy;
	}

	static function flattenQuadratic(p0:GlyphPoint, p1:GlyphPoint, p2:GlyphPoint, segments:Array<GlyphSegment>, depth:Int = 0) {
		final lineMid = midpoint(p0, p2);
		final dx = p1.x - lineMid.x;
		final dy = p1.y - lineMid.y;
		if (depth >= 8 || dx * dx + dy * dy <= sdfQuadraticFlatnessSq) {
			addGlyphSegment(segments, p0, p2);
			return;
		}

		final p01 = midpoint(p0, p1);
		final p12 = midpoint(p1, p2);
		final p012 = midpoint(p01, p12);
		flattenQuadratic(p0, p01, p012, segments, depth + 1);
		flattenQuadratic(p012, p12, p2, segments, depth + 1);
	}

	static function flattenCubic(p0:GlyphPoint, p1:GlyphPoint, p2:GlyphPoint, p3:GlyphPoint, segments:Array<GlyphSegment>, depth:Int = 0) {
		final flatness = Math.max(pointLineDistanceSq(p1, p0, p3), pointLineDistanceSq(p2, p0, p3));
		if (depth >= 10 || flatness <= sdfCubicFlatnessSq) {
			addGlyphSegment(segments, p0, p3);
			return;
		}

		final p01 = midpoint(p0, p1);
		final p12 = midpoint(p1, p2);
		final p23 = midpoint(p2, p3);
		final p012 = midpoint(p01, p12);
		final p123 = midpoint(p12, p23);
		final p0123 = midpoint(p012, p123);
		flattenCubic(p0, p01, p012, p0123, segments, depth + 1);
		flattenCubic(p0123, p123, p23, p3, segments, depth + 1);
	}

	static inline function pointSegmentDistanceSq(px:Float, py:Float, segment:GlyphSegment):Float {
		final dx = segment.bx - segment.ax;
		final dy = segment.by - segment.ay;
		final denom = dx * dx + dy * dy;
		if (denom <= 1e-8) {
			final ox = px - segment.ax;
			final oy = py - segment.ay;
			return ox * ox + oy * oy;
		}
		final t = Math.max(0.0, Math.min(1.0, ((px - segment.ax) * dx + (py - segment.ay) * dy) / denom));
		final qx = segment.ax + dx * t;
		final qy = segment.ay + dy * t;
		final ox = px - qx;
		final oy = py - qy;
		return ox * ox + oy * oy;
	}

	static inline function pointInsideGlyph(px:Float, py:Float, segments:Array<GlyphSegment>):Bool {
		var inside = false;
		for (segment in segments) {
			final ayAbove = segment.ay > py;
			final byAbove = segment.by > py;
			if (ayAbove == byAbove)
				continue;
			final x = segment.ax + (py - segment.ay) * (segment.bx - segment.ax) / (segment.by - segment.ay);
			if (x > px)
				inside = !inside;
		}
		return inside;
	}

	static function buildGlyphSegments(info:Stbtt_fontinfo, glyphIndex:Int, scale:Float, glyph:Stbtt_bakedchar):Array<GlyphSegment> {
		final vertices = StbTruetype.stbtt_GetGlyphShape(info, glyphIndex);
		if (vertices == null || vertices.length == 0)
			return [];

		final originX = glyph.xoff * sdfOversample + sdfPadding;
		final originY = glyph.yoff * sdfOversample + sdfPadding;

		inline function mapPoint(x:Int, y:Int):GlyphPoint
			return glyphPoint(x * scale - originX + sdfPadding, -y * scale - originY + sdfPadding);

		final segments:Array<GlyphSegment> = [];
		var start:GlyphPoint = null;
		var current:GlyphPoint = null;

		for (vertex in vertices) {
			switch vertex.type {
				case StbTruetype.STBTT_vmove:
					if (current != null && start != null)
						addGlyphSegment(segments, current, start);
					start = mapPoint(vertex.x, vertex.y);
					current = start;
				case StbTruetype.STBTT_vline:
					final next = mapPoint(vertex.x, vertex.y);
					addGlyphSegment(segments, current, next);
					current = next;
				case StbTruetype.STBTT_vcurve:
					final control = mapPoint(vertex.cx, vertex.cy);
					final next = mapPoint(vertex.x, vertex.y);
					flattenQuadratic(current, control, next, segments);
					current = next;
				case StbTruetype.STBTT_vcubic:
					final control1 = mapPoint(vertex.cx, vertex.cy);
					final control2 = mapPoint(vertex.cx1, vertex.cy1);
					final next = mapPoint(vertex.x, vertex.y);
					flattenCubic(current, control1, control2, next, segments);
					current = next;
				case _:
			}
		}

		if (current != null && start != null)
			addGlyphSegment(segments, current, start);

		return segments;
	}

	static function getGlyphSegments(info:Stbtt_fontinfo, glyphIndex:Int, scale:Float, glyph:Stbtt_bakedchar, glyphSegments:IntMap<Array<GlyphSegment>>,
			cacheKey:Int):Array<GlyphSegment> {
		final cached = glyphSegments.get(cacheKey);
		if (cached != null)
			return cached;

		final segments = buildGlyphSegments(info, glyphIndex, scale, glyph);
		glyphSegments.set(cacheKey, segments);
		return segments;
	}

	static function buildGlyphSdf(pixels:Blob, atlasWidth:Int, glyph:Stbtt_bakedchar, segments:Array<GlyphSegment>) {
		if (sdfFast) {
			buildGlyphSdfFast(pixels, atlasWidth, glyph, segments);
			return;
		}
		buildGlyphSdfSlow(pixels, atlasWidth, glyph, segments);
	}

	static function buildGlyphSdfFromBitmap(pixels:Blob, atlasWidth:Int, glyph:Stbtt_bakedchar, scratch:SdfScratch) {
		final width = glyph.x1 - glyph.x0;
		final height = glyph.y1 - glyph.y0;
		if (width <= 0 || height <= 0)
			return;

		final count = width * height;
		scratch.ensure(count, width > height ? width : height);
		final inside = scratch.inside;
		final outside = scratch.outside;

		for (y in 0...height) {
			final row = y * width;
			final atlasRow = (glyph.y0 + y) * atlasWidth + glyph.x0;
			for (x in 0...width) {
				final idx = row + x;
				final alphaByte = pixels.readU8(atlasRow + x);
				if (alphaByte == 0) {
					inside[idx] = sdfInf;
					outside[idx] = 0.0;
				} else if (alphaByte == 255) {
					inside[idx] = 0.0;
					outside[idx] = sdfInf;
				} else {
					final alpha = alphaByte / 255.0;
					final insideDistance = 1.0 - alpha;
					inside[idx] = insideDistance * insideDistance;
					outside[idx] = alpha * alpha;
				}
			}
		}

		final distInside = scratch.distInside;
		final distOutside = scratch.distOutside;
		edt2dInto(inside, width, height, scratch.tmp, distInside, scratch.f, scratch.d, scratch.v, scratch.z);
		edt2dInto(outside, width, height, scratch.tmp, distOutside, scratch.f, scratch.d, scratch.v, scratch.z);

		for (y in 0...height) {
			final row = y * width;
			final atlasRow = (glyph.y0 + y) * atlasWidth + glyph.x0;
			for (x in 0...width) {
				final idx = row + x;
				final signed = Math.sqrt(distOutside[idx]) - Math.sqrt(distInside[idx]);
				final normalized = 0.5 + signed / (2.0 * sdfSpread);
				pixels.writeU8(atlasRow + x, normalized <= 0.0 ? 0 : normalized >= 1.0 ? 255 : Std.int(normalized * 255.0 + 0.5));
			}
		}
	}

	static function buildGlyphSdfFast(pixels:Blob, atlasWidth:Int, glyph:Stbtt_bakedchar, segments:Array<GlyphSegment>) {
		final width = glyph.x1 - glyph.x0;
		final height = glyph.y1 - glyph.y0;
		if (width <= 0 || height <= 0)
			return;
		if (segments.length == 0)
			return;

		final count = width * height;
		final inside = new Vector<Float>(count);
		final outside = new Vector<Float>(count);
		rasterizeGlyphMask(segments, width, height, inside, outside);

		final distInside = edt2d(inside, width, height);
		final distOutside = edt2d(outside, width, height);

		final band = sdfSpread + 2.0;
		for (y in 0...height) {
			final row = y * width;
			final atlasRow = (glyph.y0 + y) * atlasWidth + glyph.x0;
			for (x in 0...width) {
				final idx = row + x;
				final approxSigned = Math.sqrt(distOutside[idx]) - Math.sqrt(distInside[idx]);
				if (approxSigned <= -band) {
					pixels.writeU8(atlasRow + x, 0);
					continue;
				}
				if (approxSigned >= band) {
					pixels.writeU8(atlasRow + x, 255);
					continue;
				}

				final px = x + 0.5;
				final py = y + 0.5;
				var minDistSq = sdfInf;
				for (segment in segments) {
					final distSq = pointSegmentDistanceSq(px, py, segment);
					if (distSq < minDistSq)
						minDistSq = distSq;
				}
				final signed = (inside[idx] == 0.0 ? 1.0 : -1.0) * Math.sqrt(minDistSq);
				final normalized = Math.max(0.0, Math.min(1.0, 0.5 + signed / (2.0 * sdfSpread)));
				pixels.writeU8(atlasRow + x, Std.int(Math.round(normalized * 255.0)));
			}
		}
	}

	static function buildGlyphSdfSlow(pixels:Blob, atlasWidth:Int, glyph:Stbtt_bakedchar, segments:Array<GlyphSegment>) {
		final width = glyph.x1 - glyph.x0;
		final height = glyph.y1 - glyph.y0;
		if (width <= 0 || height <= 0)
			return;
		if (segments.length == 0)
			return;

		for (y in 0...height) {
			for (x in 0...width) {
				final px = x + 0.5;
				final py = y + 0.5;
				var minDistSq = sdfInf;
				for (segment in segments) {
					final distSq = pointSegmentDistanceSq(px, py, segment);
					if (distSq < minDistSq)
						minDistSq = distSq;
				}
				final signed = (pointInsideGlyph(px, py, segments) ? 1.0 : -1.0) * Math.sqrt(minDistSq);
				final normalized = Math.max(0.0, Math.min(1.0, 0.5 + signed / (2.0 * sdfSpread)));
				pixels.writeU8(glyph.x0 + x + (glyph.y0 + y) * atlasWidth, Std.int(Math.round(normalized * 255.0)));
			}
		}
	}

	static function rasterizeGlyphMask(segments:Array<GlyphSegment>, width:Int, height:Int, inside:Vector<Float>, outside:Vector<Float>) {
		final count = width * height;
		for (i in 0...count) {
			inside[i] = sdfInf;
			outside[i] = 0.0;
		}

		final intersections:Array<Float> = [];
		for (y in 0...height) {
			intersections.resize(0);
			final py = y + 0.5;
			for (segment in segments) {
				final ay = segment.ay;
				final by = segment.by;
				if ((ay > py) == (by > py))
					continue;
				final x = segment.ax + (py - ay) * (segment.bx - segment.ax) / (by - ay);
				intersections.push(x);
			}
			if (intersections.length == 0)
				continue;
			intersections.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);

			var i = 0;
			while (i + 1 < intersections.length) {
				var start = Std.int(Math.ceil(intersections[i] - 0.5));
				var end = Std.int(Math.floor(intersections[i + 1] - 0.5));
				if (end >= 0 && start < width) {
					if (start < 0)
						start = 0;
					if (end >= width)
						end = width - 1;
					var idx = y * width + start;
					for (x in start...end + 1) {
						inside[idx] = 0.0;
						outside[idx] = sdfInf;
						++idx;
					}
				}
				i += 2;
			}
		}
	}

	static function edt2d(source:Vector<Float>, width:Int, height:Int):Vector<Float> {
		final tmp = new Vector<Float>(width * height);
		final out = new Vector<Float>(width * height);
		final f = new Vector<Float>(Std.int(Math.max(width, height)));
		final d = new Vector<Float>(Std.int(Math.max(width, height)));
		final v = new Vector<Int>(Std.int(Math.max(width, height)));
		final z = new Vector<Float>(Std.int(Math.max(width, height)) + 1);
		edt2dInto(source, width, height, tmp, out, f, d, v, z);
		return out;
	}

	static function edt2dInto(source:Vector<Float>, width:Int, height:Int, tmp:Vector<Float>, out:Vector<Float>, f:Vector<Float>, d:Vector<Float>, v:Vector<Int>,
			z:Vector<Float>) {
		for (x in 0...width) {
			for (y in 0...height)
				f[y] = source[y * width + x];
			edt1d(f, d, v, z, height);
			for (y in 0...height)
				tmp[y * width + x] = d[y];
		}

		for (y in 0...height) {
			for (x in 0...width)
				f[x] = tmp[y * width + x];
			edt1d(f, d, v, z, width);
			for (x in 0...width)
				out[y * width + x] = d[x];
		}
	}

	static inline function edtIntersection(f:Vector<Float>, q:Int, v:Int):Float
		return ((f[q] + q * q) - (f[v] + v * v)) / (2.0 * (q - v));

	static function edt1d(f:Vector<Float>, d:Vector<Float>, v:Vector<Int>, z:Vector<Float>, length:Int) {
		var k = 0;
		v[0] = 0;
		z[0] = Math.NEGATIVE_INFINITY;
		z[1] = Math.POSITIVE_INFINITY;

		for (q in 1...length) {
			var s = edtIntersection(f, q, v[k]);
			while (k > 0 && s <= z[k]) {
				--k;
				s = edtIntersection(f, q, v[k]);
			}
			++k;
			v[k] = q;
			z[k] = s;
			z[k + 1] = Math.POSITIVE_INFINITY;
		}

		k = 0;
		for (q in 0...length) {
			while (z[k + 1] < q)
				++k;
			final dx = q - v[k];
			d[q] = dx * dx + f[v[k]];
		}
	}

	var blob(default, set):Blob;
	var oldGlyphs:Array<Int>;
	var oldGlyphHash:Int = 0;
	var fontIndex:Int;
	var atlases:Map<Int, FontAtlas> = [];
	var glyphSegments:IntMap<Array<GlyphSegment>> = new IntMap();
	var charTemplates:IntMap<IntMap<CachedFontCharTemplate>> = new IntMap();

	inline function updateGlyphs(glyphs:Array<Int>)
		if (!glyphsEqual(glyphs, oldGlyphs)) {
			oldGlyphs = glyphs.copy();
			oldGlyphHash = hashGlyphs(oldGlyphs);
			rebuildCharBlocks(oldGlyphs);
		}

	inline function resolveFontOffset():Int {
		final offset = StbTruetype.stbtt_GetFontOffsetForIndex(blob, fontIndex);
		return offset == -1 ? StbTruetype.stbtt_GetFontOffsetForIndex(blob, 0) : offset;
	}

	inline function ensureAtlasTemplates(atlasKey:Int):IntMap<CachedFontCharTemplate> {
		var atlasTemplates = charTemplates.get(atlasKey);
		if (atlasTemplates == null)
			charTemplates.set(atlasKey, atlasTemplates = new IntMap());
		return atlasTemplates;
	}

	public function getAtlas(size:Int) @:privateAccess {
		final nominalSize = quantizeAtlasSize(size > 0 ? size : 1);
		final bakedFontSize = nominalSize * sdfOversample;
		final glyphs = sanitizeGlyphs(kha.graphics2.Graphics.fontGlyphs);
		updateGlyphs(glyphs);

		var index = makeAtlasKey(fontIndex, nominalSize, oldGlyphHash);
		var atlas = atlases.get(index);
		if (atlas != null)
			return atlas;

		final offset = resolveFontOffset();

		var atlasSize = estimateAtlasSize(blob, offset, bakedFontSize, oldGlyphs, sdfPadding);
		var width:Int = atlasSize.width;
		var height:Int = atlasSize.height;
		var baked = new Vector<Stbtt_bakedchar>(oldGlyphs.length);
		for (i in 0...baked.length)
			baked[i] = new Stbtt_bakedchar();

		var pixels:Blob = null;
		var status:Int = -1;
		while (status <= 0) {
			pixels = Blob.alloc(width * height);
			status = bakeFontBitmap(blob, offset, bakedFontSize, pixels, width, height, oldGlyphs, baked, fontIndex, bakedFontSize, glyphSegments);
			if (status <= 0)
				height < width ? height *= 2 : width *= 2;
		}

		// TODO: Scale pixels down if they exceed the supported texture size

		var info = new Stbtt_fontinfo();
		StbTruetype.stbtt_InitFont(info, blob, offset);

		var metrics = StbTruetype.stbtt_GetFontVMetrics(info);
		var scale = StbTruetype.stbtt_ScaleForPixelHeight(info, bakedFontSize);
		var ascent = Math.round(metrics.ascent * scale / sdfOversample); // equals baseline
		var descent = Math.round(metrics.descent * scale / sdfOversample);
		var lineGap = Math.round(metrics.lineGap * scale / sdfOversample);

		atlas = new FontAtlas(nominalSize, ascent, descent, lineGap, width, height, baked, pixels, oldGlyphs, sdfSpread);
		atlases.set(index, atlas);

		return atlas;
	}

	public function getFontCharTemplate(atlas:FontAtlas, char:Int):CachedFontCharTemplate @:privateAccess {
		final atlasKey = makeAtlasKey(fontIndex, atlas.size, oldGlyphHash);
		final atlasTemplates = ensureAtlasTemplates(atlasKey);
		final glyphIndex = atlas.getCharIndex(char);
		final cached = atlasTemplates.get(glyphIndex);
		if (cached != null)
			return cached;

		final g = atlas.chars[glyphIndex];
		final atlasW:Float = g.x1 - g.x0;
		final atlasH:Float = g.y1 - g.y0;
		final built:CachedFontCharTemplate = {
			xoff: g.xoff,
			yoff: g.yoff,
			advance: g.xadvance,
			width: atlasW / sdfOversample,
			height: atlasH / sdfOversample,
			uvX: g.x0 / atlas.width,
			uvY: g.y0 / atlas.height,
			uvWidth: atlasW / atlas.width,
			uvHeight: atlasH / atlas.height
		};
		atlasTemplates.set(glyphIndex, built);
		return built;
	}

	public function widthOfCharacters(size:Int, characters:Array<Int>, start:Int, length:Int) {
		if (size <= 0 || characters == null || length <= 0)
			return 0.0;

		final atlas = getAtlas(size);
		final scale = size / atlas.size;
		final end = Std.int(Math.min(start + length, characters.length));
		var width = 0.0;
		for (i in start...end)
			width += atlas.getGlyph(characters[i]).xadvance * scale;
		return width;
	}

	function fromResource(resource:kha.Font):Void @:privateAccess {
		blob = resource.blob;
		oldGlyphs = resource.oldGlyphs;
		oldGlyphHash = oldGlyphs != null ? hashGlyphs(oldGlyphs) : 0;
		if (oldGlyphs != null && oldGlyphs.length > 0)
			rebuildCharBlocks(oldGlyphs);
		fontIndex = resource.fontIndex;
		atlases = cast resource.images;
		if (atlases == null)
			atlases = [];
		glyphSegments = new IntMap();
		charTemplates = new IntMap();
	}

	function toResource():kha.Font @:privateAccess {
		var font = new kha.Font(blob);
		font.oldGlyphs = oldGlyphs != null ? oldGlyphs.copy() : null;
		font.fontIndex = fontIndex;
		font.images = cast atlases;
		return font;
	}

	function unload()
		blob = null;

	function set_blob(value:Blob):Blob {
		if ((blob = value) != null)
			notifyLoaded();
		return blob;
	}

	function get_isLoaded():Bool
		return blob != null;
}
