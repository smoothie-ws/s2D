package s.ui.graphics.shapes;

import s.graphics.RenderTarget;
import s.graphics.ConstantLocation;

@:allow(s.ui.shapes.Shape)
@:access(s.ui.elements.Drawable)
abstract class ShapeDrawer<T:s.ui.shapes.Shape> extends ElementDrawer<T> {
	var radiusCL:ConstantLocation;
	var softnessCL:ConstantLocation;
	var borderColorCL:ConstantLocation;
	var borderWidthCL:ConstantLocation;
	var borderSoftnessCL:ConstantLocation;

	public function new(fragmentShader:String) {
		super(fragmentShader);
	}

	override function setup() {
		super.setup();
		radiusCL = pipeline.getConstantLocation("radius");
		softnessCL = pipeline.getConstantLocation("softness");
		borderWidthCL = pipeline.getConstantLocation("borderWidth");
		borderColorCL = pipeline.getConstantLocation("borderColor");
		borderSoftnessCL = pipeline.getConstantLocation("borderSoftness");
	}

	override function setUniforms(target:RenderTarget, element:T) {
		final ctx = target.context3D;
		final s = Math.max(element.softness, element.border.softness) + Math.max(-element.border.width, 0.0);
		ctx.setMat3(mvpCL, element.realTransform * target.context2D.transform);
		ctx.setVec4(rectCL, element.left.position - s, element.top.position - s, element.width + s * 2.0, element.height + s * 2.0);
		ctx.setVec4(colorCL, element.realColor);
		ctx.setFloat(radiusCL, element.realRadius);
		ctx.setFloat(softnessCL, element.softness);
		ctx.setVec4(borderColorCL, element.border.color);
		ctx.setFloat(borderWidthCL, element.border.width);
		ctx.setFloat(borderSoftnessCL, element.border.softness);
	}
}
