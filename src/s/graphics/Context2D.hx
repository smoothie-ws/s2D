package s.graphics;

import haxe.Rest;
import s.assets.AnimatedImage;
import s.math.Vec2;
import s.math.Mat3;
import s.math.SMath;
import s.assets.Image;
import s.geometry.Rect;
import s.graphics.FontStyle;
import s.ui.Alignment;

using s.extensions.StringExt;

class Context2DStyle implements s.shortcut.Shortcut {
	final opacities:Array<Float> = [];

	public var color:Color = Black;
	public final font:FontStyle = new FontStyle();
	@:alias public var opacity:Float = opacities[opacities.length - 1];

	public inline function new()
		opacities.push(1.0);

	public function reset():Void {
		color = Black;
		font.setDefault();
		opacities.resize(0);
		opacities.push(1.0);
	}

	public inline function pushOpacity(value:Float)
		opacities.push(opacity * value);

	public inline function popOpacity():Float
		return opacities.pop();
}

@:allow(s.graphics.RenderTarget)
@:allow(s.graphics.shaders.Shader2D)
class Context2D implements s.shortcut.Shortcut {
	final context:Context3D;
	final transforms:Array<Mat3> = [];

	public final style:Context2DStyle = new Context2DStyle();
	@:alias public var transform:Mat3 = transforms[transforms.length - 1];

	function new(context:Context3D) {
		this.context = context;
		transforms.push(Mat3.identity());
	}

	public inline function begin() {
		style.reset();
		context.reset();
	}

	public inline function clear(color:Color = Transparent)
		context.clear(color);

	public inline function end()
		context.execute();

	public inline function scissor(x:Int, y:Int, width:Int, height:Int)
		context.scissor(x, y, width, height);

	public inline function disableScissor()
		context.disableScissor();

	public inline function draw(clear:Bool = true, clearColor:Color = Transparent, commands:Context2D->Void) {
		begin();
		if (clear)
			this.clear(clearColor);
		commands(this);
		end();
	}

	public inline function drawScissored(x:Int, y:Int, width:Int, height:Int, commands:Context2D->Void) {
		scissor(x, y, width, height);
		commands(this);
		disableScissor();
	}

	public inline function pushTransform(value:Mat3):Void
		transforms.push(value * transform);

	public inline function popTransform():Mat3
		return transforms.length > 1 ? transforms.pop() : null;

	overload extern public inline function drawLine(p1:Vec2, p2:Vec2, strength:Float = 1.0)
		drawLine(p1.x, p1.y, p2.x, p2.y, strength);

	overload extern public inline function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, strength:Float = 1.0) {
		var dx = x2 - x1;
		var dy = y2 - y1;
		pushTransform(Mat3.translation(-x1, -y1));
		pushTransform(Mat3.rotation(x1, y1, x2, y2));
		pushTransform(Mat3.translation(x1, y1));
		fillRectangle(x1, y1 - strength * 0.5, sqrt(dx * dx + dy * dy), strength);
		popTransform();
	}

	overload extern public inline function drawPath(strength:Float = 1.0, points:Rest<Vec2>)
		drawPath(strength, points);

	overload extern public inline function drawPath(strength:Float = 1.0, points:Array<Vec2>)
		if (points?.length >= 2)
			for (i in 1...points.length)
				drawLine(points[i - 1], points[i], strength);

	overload extern public inline function drawRectangle(rect:Rect, strength:Float = 1.0)
		drawRectangle(rect.x, rect.y, rect.width, rect.height, strength);

	overload extern public inline function drawRectangle(x:Float, y:Float, width:Float, height:Float, strength:Float = 1.0)
		drawRectangle(x, y, x + width, y, x + width, y + height, x, y + height);

	overload extern public inline function drawRectangle(p1:Vec2, p2:Vec2, p3:Vec2, p4:Vec2, strength:Float = 1.0)
		drawRectangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);

	overload extern public inline function drawRectangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, strength:Float = 1.0) {
		drawLine(x1, y1, x2, y2, strength);
		drawLine(x2, y2, x3, y3, strength);
		drawLine(x3, y3, x4, y4, strength);
		drawLine(x4, y4, x1, y1, strength);
	}

	overload extern public inline function fillRectangle(rect:Rect)
		fillRectangle(rect.x, rect.y, rect.width, rect.height);

	overload extern public inline function fillRectangle(x:Float, y:Float, width:Float, height:Float)
		s.graphics.shaders.RectangleShader.shader.render(this, x, y, width, height);

	overload extern public inline function drawTriangle(p1:Vec2, p2:Vec2, p3:Vec2, strength:Float = 1.0)
		drawTriangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);

	overload extern public inline function drawTriangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, strength:Float = 1.0) {
		drawLine(x1, y1, x2, y2, strength);
		drawLine(x2, y2, x3, y3, strength);
		drawLine(x3, y3, x1, y1, strength);
	}

	overload extern public inline function fillTriangle(p1:Vec2, p2:Vec2, p3:Vec2)
		fillTriangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);

	overload extern public inline function fillTriangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float)
		s.graphics.shaders.TriangleShader.shader.render(this, x1, y1, x2, y2, x3, y3);

	public inline function drawImage(img:Image, x:Float, y:Float)
		drawScaledSubImage(img, 0.0, 0.0, img.width, img.height, x, y, img.width, img.height);

	/**
	 * `sx, sy, sw, sh` arguments is the sub-rectangle of the source `img` image
	 */
	public inline function drawSubImage(img:Image, x:Float, y:Float, sx:Float, sy:Float, sw:Float, sh:Float)
		drawScaledSubImage(img, sx, sy, sw, sh, x, y, sw, sh);

	/**
	 * `dx, dy, dw, dh` arguments is the rectangle to draw into the destination context
	 */
	public inline function drawScaledImage(img:Image, dx:Float, dy:Float, dw:Float, dh:Float)
		drawScaledSubImage(img, 0.0, 0.0, img.width, img.height, dx, dy, dw, dh);

	/**
	 * `sx, sy, sw, sh` arguments is the sub-rectangle of the source `img` image
	 * `dx, dy, dw, dh` arguments is the rectangle to draw into the destination context
	 */
	public inline function drawScaledSubImage(img:Image, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float)
		s.graphics.shaders.ImageShader.shader.render(this, img, sx, sy, sw, sh, dx, dy, dw, dh);

	public inline function drawAnimatedImage(img:AnimatedImage, x:Float, y:Float)
		drawSubImage(img, x, y, img.currentFrame.x, img.currentFrame.y, img.width, img.height);

	public inline function drawAnimatedSubImage(img:AnimatedImage, x:Float, y:Float, sx:Float, sy:Float, sw:Float, sh:Float)
		drawSubImage(img, x, y, img.currentFrame.x + sx, img.currentFrame.y + sy, sw, sh);

	public inline function drawAnimatedScaledImage(img:AnimatedImage, dx:Float, dy:Float, dw:Float, dh:Float)
		drawScaledSubImage(img, img.currentFrame.x, img.currentFrame.y, img.width, img.height, dx, dy, dw, dh);

	public inline function drawAnimatedScaledSubImage(img:AnimatedImage, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float)
		drawScaledSubImage(img, img.currentFrame.x + sx, img.currentFrame.y + sy, sw, sh, dx, dy, dw, dh);

	/**
	 * Draws a arc.
	 * @param	ccw (optional) Specifies whether the drawing should be counterclockwise.
	 * @param	segments (optional) The amount of lines that should be used to render the arc.
	 */
	public inline function drawArc(cx:Float, cy:Float, radius:Float, sAngle:Float, eAngle:Float, strength:Float = 1, ccw:Bool = false, segments:Int = 0):Void {
		#if kha_html5
		if (kha.SystemImpl.gl == null) {
			var g:kha.js.CanvasGraphics = cast this;
			radius -= strength / 2; // reduce radius to fit the line thickness within image width/height
			g.drawArc(cx, cy, radius, sAngle, eAngle, strength, ccw);
			return;
		}
		#end

		sAngle = sAngle % (Math.PI * 2);
		eAngle = eAngle % (Math.PI * 2);

		if (ccw) {
			if (eAngle > sAngle)
				eAngle -= Math.PI * 2;
		} else if (eAngle < sAngle)
			eAngle += Math.PI * 2;

		radius += strength / 2;
		if (segments <= 0)
			segments = Math.floor(10 * Math.sqrt(radius));

		var theta = (eAngle - sAngle) / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);

		var x = Math.cos(sAngle) * radius;
		var y = Math.sin(sAngle) * radius;

		for (n in 0...segments) {
			var px = x + cx;
			var py = y + cy;

			var t = x;
			x = c * x - s * y;
			y = c * y + s * t;

			drawInnerLine(x + cx, y + cy, px, py, strength);
		}
	}

	/**
	 * Draws a filled arc.
	 * @param	ccw (optional) Specifies whether the drawing should be counterclockwise.
	 * @param	segments (optional) The amount of lines that should be used to render the arc.
	 */
	public inline function fillArc(cx:Float, cy:Float, radius:Float, sAngle:Float, eAngle:Float, ccw:Bool = false, segments:Int = 0):Void {
		#if kha_html5
		if (kha.SystemImpl.gl == null) {
			var g:kha.js.CanvasGraphics = cast this;
			g.fillArc(cx, cy, radius, sAngle, eAngle, ccw);
			return;
		}
		#end

		sAngle = sAngle % (Math.PI * 2);
		eAngle = eAngle % (Math.PI * 2);

		if (ccw) {
			if (eAngle > sAngle)
				eAngle -= Math.PI * 2;
		} else if (eAngle < sAngle)
			eAngle += Math.PI * 2;

		if (segments <= 0)
			segments = Math.floor(10 * Math.sqrt(radius));

		var theta = (eAngle - sAngle) / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);

		var x = Math.cos(sAngle) * radius;
		var y = Math.sin(sAngle) * radius;
		var sx = x + cx;
		var sy = y + cy;

		for (n in 0...segments) {
			var px = x + cx;
			var py = y + cy;

			var t = x;
			x = c * x - s * y;
			y = c * y + s * t;

			fillTriangle(px, py, x + cx, y + cy, sx, sy);
		}
	}

	/**
	 * Draws a circle.
	 * @param	segments (optional) The amount of lines that should be used to render the circle.
	 */
	public inline function drawCircle(cx:Float, cy:Float, radius:Float, strength:Float = 1, segments:Int = 0):Void {
		#if kha_html5
		if (kha.SystemImpl.gl == null) {
			var g:kha.js.CanvasGraphics = cast this;
			radius -= strength / 2; // reduce radius to fit the line thickness within image width/height
			g.drawCircle(cx, cy, radius, strength);
			return;
		}
		#end
		radius += strength / 2;

		if (segments <= 0)
			segments = Math.floor(10 * Math.sqrt(radius));

		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);

		var x = radius;
		var y = 0.0;

		for (n in 0...segments) {
			var px = x + cx;
			var py = y + cy;

			var t = x;
			x = c * x - s * y;
			y = c * y + s * t;
			drawInnerLine(x + cx, y + cy, px, py, strength);
		}
	}

	private inline function drawInnerLine(x1:Float, y1:Float, x2:Float, y2:Float, strength:Float):Void {
		var side = y2 > y1 ? 1 : 0;
		if (y2 == y1)
			side = x2 - x1 > 0 ? 1 : 0;

		var vec:Vec2;
		if (y2 == y1)
			vec = vec2(0, -1);
		else
			vec = vec2(1, -(x2 - x1) / (y2 - y1));
		vec.setLength(strength);
		var p1 = vec2(x1 + side * vec.x, y1 + side * vec.y);
		var p2 = vec2(x2 + side * vec.x, y2 + side * vec.y);
		var p3 = p1 - vec;
		var p4 = p2 - vec;
		fillTriangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
		fillTriangle(p3.x, p3.y, p2.x, p2.y, p4.x, p4.y);
	}

	/**
	 * Draws a filled circle.
	 * @param	segments (optional) The amount of lines that should be used to render the circle.
	 */
	public inline function fillCircle(cx:Float, cy:Float, radius:Float, segments:Int = 0):Void {
		#if kha_html5
		if (kha.SystemImpl.gl == null) {
			var g:kha.js.CanvasGraphics = cast this;
			g.fillCircle(cx, cy, radius);
			return;
		}
		#end

		if (segments <= 0) {
			segments = Math.floor(10 * Math.sqrt(radius));
		}

		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);

		var x = radius;
		var y = 0.0;

		for (n in 0...segments) {
			var px = x + cx;
			var py = y + cy;

			var t = x;
			x = c * x - s * y;
			y = c * y + s * t;

			fillTriangle(px, py, x + cx, y + cy, cx, cy);
		}
	}

	/**
	 * Draws a convex polygon.
	 */
	public inline function drawPolygon(x:Float, y:Float, vertices:Array<Vec2>, strength:Float = 1) {
		var iterator = vertices.iterator();
		var v0 = iterator.next();
		var v1 = v0;

		while (iterator.hasNext()) {
			var v2 = iterator.next();
			drawLine(v1.x + x, v1.y + y, v2.x + x, v2.y + y, strength);
			v1 = v2;
		}
		drawLine(v1.x + x, v1.y + y, v0.x + x, v0.y + y, strength);
	}

	/**
	 * Draws a filled convex polygon.
	 */
	public inline function fillPolygon(x:Float, y:Float, vertices:Array<Vec2>) {
		var iterator = vertices.iterator();

		if (!iterator.hasNext())
			return;
		var v0 = iterator.next();

		if (!iterator.hasNext())
			return;
		var v1 = iterator.next();

		while (iterator.hasNext()) {
			var v2 = iterator.next();
			fillTriangle(v0.x + x, v0.y + y, v1.x + x, v1.y + y, v2.x + x, v2.y + y);
			v1 = v2;
		}
	}

	/**
	 * Draws a cubic bezier using 4 pairs of points. If the x and y arrays have a length bigger then 4, the additional
	 * points will be ignored. With a length smaller of 4 a error will occur, there is no check for this.
	 * You can construct the curves visually in Inkscape with a path using default nodes.
	 * Provide x and y in the following order: startPoint, controlPoint1, controlPoint2, endPoint
	 * Reference: http://devmag.org.za/2011/04/05/bzier-curves-a-tutorial/
	 */
	public inline function drawCubicBezier(x:Array<Float>, y:Array<Float>, segments:Int = 20, strength:Float = 1.0):Void {
		var t:Float;

		var q0 = calculateCubicBezierPoint(0, x, y);
		var q1:Array<Float>;

		for (i in 1...(segments + 1)) {
			t = i / segments;
			q1 = calculateCubicBezierPoint(t, x, y);
			drawLine(q0[0], q0[1], q1[0], q1[1], strength);
			q0 = q1;
		}
	}

	/**
	 * Draws multiple cubic beziers joined by the end point. The minimum size is 4 pairs of points (a single curve).
	 */
	public inline function drawCubicBezierPath(x:Array<Float>, y:Array<Float>, segments:Int = 20, strength:Float = 1.0):Void {
		var i = 0;
		var t:Float;
		var q0:Array<Float> = null;
		var q1:Array<Float> = null;

		while (i < x.length - 3) {
			if (i == 0)
				q0 = calculateCubicBezierPoint(0, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);

			for (j in 1...(segments + 1)) {
				t = j / segments;
				q1 = calculateCubicBezierPoint(t, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);
				drawLine(q0[0], q0[1], q1[0], q1[1], strength);
				q0 = q1;
			}

			i += 3;
		}
	}

	private inline function calculateCubicBezierPoint(t:Float, x:Array<Float>, y:Array<Float>):Array<Float> {
		var u:Float = 1 - t;
		var tt:Float = t * t;
		var uu:Float = u * u;
		var uuu:Float = uu * u;
		var ttt:Float = tt * t;

		// first term
		var p:Array<Float> = [uuu * x[0], uuu * y[0]];

		// second term
		p[0] += 3 * uu * t * x[1];
		p[1] += 3 * uu * t * y[1];

		// third term
		p[0] += 3 * u * tt * x[2];
		p[1] += 3 * u * tt * y[2];

		// fourth term
		p[0] += ttt * x[3];
		p[1] += ttt * y[3];

		return p;
	}

	/**
	 * Draws a quadratic bezier using 3 pairs of points. 
	 * Provide x and y in the following order: startPoint, controlPoint, endPoint
	 */
	public inline function drawQuadraticBezier(x:Array<Float>, y:Array<Float>, segments:Int = 20, strength:Float = 1.0):Void {
		var t:Float;

		var q0 = calculateQuadraticBezierPoint(0, x, y);
		var q1:Array<Float>;

		for (i in 1...(segments + 1)) {
			t = i / segments;
			q1 = calculateQuadraticBezierPoint(t, x, y);
			drawLine(q0[0], q0[1], q1[0], q1[1], strength);
			q0 = q1;
		}
	}

	/**
	 * Draws multiple quadratic beziers joined by the end point. The minimum size is 3 pairs of points (a single curve).
	 */
	public inline function drawQuadraticBezierPath(x:Array<Float>, y:Array<Float>, segments:Int = 20, strength:Float = 1.0):Void {
		var i = 0;
		var t:Float;
		var q0:Array<Float> = null;
		var q1:Array<Float> = null;

		while (i < x.length - 2) {
			if (i == 0)
				q0 = calculateQuadraticBezierPoint(0, [x[i], x[i + 1], x[i + 2]], [y[i], y[i + 1], y[i + 2]]);

			for (j in 1...(segments + 1)) {
				t = j / segments;
				q1 = calculateQuadraticBezierPoint(t, [x[i], x[i + 1], x[i + 2]], [y[i], y[i + 1], y[i + 2]]);
				drawLine(q0[0], q0[1], q1[0], q1[1], strength);
				q0 = q1;
			}

			i += 3;
		}
	}

	private inline function calculateQuadraticBezierPoint(t:Float, x:Array<Float>, y:Array<Float>):Array<Float> {
		var u:Float = 1 - t;
		var tt:Float = t * t;
		var uu:Float = u * u;

		// first term
		var p:Array<Float> = [uu * x[0], uu * y[0]];

		// second term
		p[0] += 2 * u * t * x[1];
		p[1] += 2 * u * t * y[1];

		// third term
		p[0] += tt * x[2];
		p[1] += tt * y[2];

		return p;
	}

	public inline function drawFontChars(chars:Array<FontChar>)
		s.graphics.shaders.TextShader.shader.render(this, chars);

	public inline function drawString(text:String, x:Float, y:Float)
		drawCharacters(text.toCharArray(), 0, text.length, x, y);

	public inline function drawCharacters(text:Array<Int>, start:Int, length:Int, x:Float, y:Float) {
		var offset = x;
		final snappedY = style.font.snapToPixel ? Math.round(y) : y;
		drawFontChars([
			for (c in text.slice(start, start + length)) {
				var char = style.font.getFontChar(c);
				char.pos.x = offset + char.xoff;
				char.pos.y = snappedY + char.yoff;
				offset += char.advance;
				char;
			}
		]);
	}

	public inline function drawAlignedString(text:String, x:Float, y:Float, alignment:Alignment):Void
		drawAlignedCharacters(text.toCharArray(), 0, text.length, x, y, alignment);

	public inline function drawAlignedCharacters(text:Array<Int>, start:Int, length:Int, x:Float, y:Float, alignment:Alignment):Void {
		var xoffset = 0.0;
		if (alignment & AlignHCenter != 0 || alignment & AlignRight != 0) {
			var width = style.font.widthOfCharacters(text, start, length);
			if (alignment & AlignHCenter != 0)
				xoffset = -width * 0.5;
			else
				xoffset = -width;
		}
		var yoffset = 0.0;
		if (alignment & AlignVCenter != 0 || alignment & AlignBottom != 0) {
			if (alignment & AlignVCenter != 0)
				yoffset = -style.font.size * 0.5;
			else
				yoffset = -style.font.size;
		}
		drawCharacters(text, start, length, x + xoffset, y + yoffset);
	}
}
