package s.stage2d.graphics.postprocessing;

import kha.Shaders;
import kha.arrays.Float32Array;
import s.Color;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.RenderTarget;

class Compositor extends PPEffect {
	var textureMapTU:TextureUnit;
	var paramsCL:ConstantLocation;

	var params:Float32Array;

	public var letterBoxHeight:Int = 0;
	public var letterBoxColor:Color = "black";
	public var posterizeGamma(get, set):Float;
	public var posterizeSteps(get, set):Float;
	public var vignetteStrength(get, set):Float;
	public var vignetteColor(get, set):Color;

	public function new() {
		super();

		params = new Float32Array(7);
		posterizeGamma = 1.0;
		posterizeSteps = 255.0;
		vignetteStrength = 0.0;
		vignetteColor = "black";
	}

	function setPipeline() {
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "compositor_frag");
	}

	function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		paramsCL = pipeline.getConstantLocation("params");
	}

	// @:access(s.stage2d.graphics.Renderer)
	function render(target:RenderTarget) {
		// final ctx = target.context2D;
		// final ctx3d = target.context3D;

		// ctx.begin();
		// ctx3d.scissor(0, letterBoxHeight, s.sengine.width, s.sengine.height - letterBoxHeight * 2);
		// ctx3d.setPipeline(pipeline);
		// ctx3d.setIndexBuffer(@:privateAccess s.sengine.indices);
		// ctx3d.setVertexBuffer(@:privateAccess s.sengine.vertices);
		// ctx3d.setTexture(textureMapTU, Renderer.buffer.src);
		// ctx3d.setFloats(paramsCL, params);
		// ctx3d.draw();
		// ctx3d.disableScissor();
		// ctx.end();
	}

	function get_posterizeGamma():Float {
		return params[0];
	}

	function set_posterizeGamma(value:Float):Float {
		params[0] = value;
		return value;
	}

	function get_posterizeSteps():Float {
		return params[1];
	}

	function set_posterizeSteps(value:Float):Float {
		params[1] = value;
		return value;
	}

	function get_vignetteStrength():Float {
		return params[2];
	}

	function set_vignetteStrength(value:Float):Float {
		params[2] = value;
		return value;
	}

	function get_vignetteColor():Color {
		return Color.rgba(params[3], params[4], params[5], params[6]);
	}

	function set_vignetteColor(value:Color):Color {
		params[3] = value.r;
		params[4] = value.g;
		params[5] = value.b;
		params[6] = value.a;
		return value;
	}
}
