package s.graphics.shaders;

import s.graphics.FontStyle;
import s.graphics.ConstantLocation;
import s.graphics.TextureParameters;

class TextShader extends TexturedShader {
	var sdfRangeCL:ConstantLocation;
	var sourceInvSizeCL:ConstantLocation;
	var outlineColorCL:ConstantLocation;
	var outlineWidthCL:ConstantLocation;
	var softnessCL:ConstantLocation;
	var weightCL:ConstantLocation;

	function new() {
		super("text2d", "shader2d");
	}

	override function setup() {
		super.setup();
		sdfRangeCL = pipeline.getConstantLocation("sdfRange");
		sourceInvSizeCL = pipeline.getConstantLocation("sourceInvSize");
		outlineColorCL = pipeline.getConstantLocation("outlineColor");
		outlineWidthCL = pipeline.getConstantLocation("outlineWidth");
		softnessCL = pipeline.getConstantLocation("softness");
		weightCL = pipeline.getConstantLocation("weight");
	}

	inline function spacing(font:FontStyle, char:Int):Float {
		var spacing = font.letterSpacing;
		if (char == " ".code || char == "\t".code)
			spacing += font.wordSpacing;
		return spacing;
	}

	public function render(context:Context2D, chars:Array<FontChar>) {
		if (chars == null || chars.length == 0)
			return;

		if (!compiled)
			compile();
		
		super.set(context);

		final ctx = context.context;
		final style = context.style;
		final font = style.font;
		final atlas = font.getAtlas();
		final outlineColor = font.outlineColor;

		ctx.setTexture(sourceTU, atlas.getTexture(), Clamp, Clamp, LinearFilter, LinearFilter, NoMipFilter);
		ctx.setFloat(sdfRangeCL, atlas.sdfRange);
		ctx.setVec2(sourceInvSizeCL, 1.0 / atlas.width, 1.0 / atlas.height);
		ctx.setVec4(outlineColorCL, outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a * style.opacity);
		ctx.setFloat(outlineWidthCL, font.outlineWidth);
		ctx.setFloat(softnessCL, font.softness);
		ctx.setFloat(weightCL, font.sdfWeight);

		for (c in chars) {
			var h = c.pos.height;
			if (h == 0)
				continue;

			var yTop = c.pos.y;
			var yBottom = c.pos.y + h;
			var yoff = c.yoff;
			var slantTop = -font.italicSlant * yoff;
			var slantBottom = -font.italicSlant * (yoff + h);
			var xLeftTop = c.pos.x + slantTop;
			var xRightTop = c.pos.x + c.pos.width + slantTop;
			var xLeftBottom = c.pos.x + slantBottom;
			var xRightBottom = c.pos.x + c.pos.width + slantBottom;

			ctx.addPolygon([
				[xLeftBottom, yBottom, c.uv.x, c.uv.y + c.uv.height],
				[xLeftTop, yTop, c.uv.x, c.uv.y],
				[xRightTop, yTop, c.uv.x + c.uv.width, c.uv.y],
				[xRightBottom, yBottom, c.uv.x + c.uv.width, c.uv.y + c.uv.height]
			]);
		}

		ctx.flush();
	}
}
