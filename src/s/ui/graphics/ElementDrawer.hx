package s.ui.graphics;

import s.graphics.RenderTarget;
import s.graphics.ConstantLocation;
import s.graphics.shaders.Shader;
import s.ui.elements.Drawable;

@:allow(s.ui.elements.Drawable)
@:access(s.ui.elements.Drawable)
abstract class ElementDrawer<T:Drawable> extends Shader {
	var mvpCL:ConstantLocation;
	var rectCL:ConstantLocation;
	var colorCL:ConstantLocation;

	function new(frag:String, vert:String = "element") {
		super({
			inputLayout: [Shader.structure2D],
			vertexShader: vert,
			fragmentShader: frag,
			alphaBlendSource: BlendOne,
			alphaBlendDestination: InverseSourceAlpha,
			blendSource: SourceAlpha,
			blendDestination: InverseSourceAlpha
		});
	}

	override function setup() {
		mvpCL = pipeline.getConstantLocation("mvp");
		rectCL = pipeline.getConstantLocation("rect");
		colorCL = pipeline.getConstantLocation("color");
	}

	public function render(target:RenderTarget, element:T) {
		if (!compiled)
			compile();
		final ctx = target.context3D;
		ctx.setPipeline(pipeline);
		setBuffers(target);
		setUniforms(target, element);
		draw(target, element);
	}

	function setUniforms(target:RenderTarget, element:T) {
		final ctx = target.context3D;
		ctx.setMat3(mvpCL, element.realTransform * target.context2D.transform);
		ctx.setVec4(rectCL, element.left.position, element.top.position, element.width, element.height);
		ctx.setVec4(colorCL, element.realColor);
	}

	function setBuffers(target:RenderTarget) {
		final ctx = target.context3D;
		ctx.setMesh(Shader.quad);
	}

	function draw(target:RenderTarget, element:T):Void {
		final ctx = target.context3D;
		ctx.flush();
	}
}
