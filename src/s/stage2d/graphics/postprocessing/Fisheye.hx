package s.stage2d.graphics.postprocessing;

import kha.Shaders;
import s.math.Vec2;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.RenderTarget;

class Fisheye extends PPEffect {
	var textureMapTU:TextureUnit;
	var positionCL:ConstantLocation;
	var strengthCL:ConstantLocation;

	public var position:Vec2 = new Vec2(0.5, 0.5);
	public var strength:Float = 0.0;

	function setPipeline() {
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "fisheye_frag");
	}

	function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		positionCL = pipeline.getConstantLocation("fisheyePosition");
		strengthCL = pipeline.getConstantLocation("fisheyeStrength");
	}

	// @:access(s.stage2d.graphics.Renderer)
	function render(target:RenderTarget) {
		// final ctx = target.context2D;
		// final ctx3d = target.context3D;

		// ctx.begin();
		// ctx3d.setPipeline(pipeline);
		// ctx3d.setIndexBuffer(@:privateAccess s.sengine.indices);
		// ctx3d.setVertexBuffer(@:privateAccess s.sengine.vertices);
		// ctx3d.setTexture(textureMapTU, Renderer.buffer.src);
		// ctx3d.setVec2(positionCL, position);
		// ctx3d.setFloat(strengthCL, strength);
		// ctx3d.draw();
		// ctx.end();
	}
}
