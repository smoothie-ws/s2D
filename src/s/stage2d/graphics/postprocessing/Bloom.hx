package s.stage2d.graphics.postprocessing;

import kha.Shaders;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.RenderTarget;

class Bloom extends PPEffect {
	var textureMapTU:TextureUnit;
	var paramsCL:ConstantLocation;

	public var radius:Float = 8.0;
	public var threshold:Float = 0.25;
	public var intensity:Float = 0.75;

	function setPipeline() {
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "bloom_frag");
	}

	function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		paramsCL = pipeline.getConstantLocation("params");
	}

	// @:access(s.stage2d.graphics.Renderer)
	function render(target:RenderTarget) {
		// final ctx = target.context2D;
		// final ctx3d = target.context3D;

		// Renderer.buffer.src.generateMipmaps(4);

		// ctx.begin();
		// ctx3d.setPipeline(pipeline);
		// ctx3d.setIndexBuffer(@:privateAccess s.sengine.indices);
		// ctx3d.setVertexBuffer(@:privateAccess s.sengine.vertices);
		// ctx3d.setTexture(textureMapTU, Renderer.buffer.src);
		// ctx3d.setTextureParameters(textureMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		// ctx3d.setFloat3(paramsCL, radius, threshold, intensity);
		// ctx3d.draw();
		// ctx.end();
	}
}
