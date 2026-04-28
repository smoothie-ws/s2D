package s.stage2d.graphics.postprocessing;

import kha.Shaders;
import s.math.Mat3;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.RenderTarget;

class Filter extends PPEffect {
	var textureMapTU:TextureUnit;
	var kernelCL:ConstantLocation;

	public var kernels:Array<Mat3> = [];

	public function addKernel(kernel:Mat3) {
		kernels.push(kernel);
	}

	function setPipeline() {
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "filter_frag");
	}

	function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		kernelCL = pipeline.getConstantLocation("kernel");
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
		// for (kernel in kernels) {
		// 	ctx3d.setMat3(kernelCL, kernel);
		// 	ctx3d.draw();
		// }
		// ctx.end();
	}

	public static var Sharpen(get, never):Mat3;

	static private function get_Sharpen() {
		return new Mat3(0, -1, 0, -1, 5, -1, 0, -1, 0);
	}

	public static var BoxBlur(get, never):Mat3;

	static private function get_BoxBlur() {
		return new Mat3(0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111);
	}

	public static var GaussianBlur(get, never):Mat3;

	static private function get_GaussianBlur() {
		return new Mat3(0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625);
	}

	public static var EdgeDetectionVertical(get, never):Mat3;

	static private function get_EdgeDetectionVertical() {
		return new Mat3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	}

	public static var EdgeDetectionHorizontal(get, never):Mat3;

	static private function get_EdgeDetectionHorizontal() {
		return new Mat3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	}

	public static var EdgeDetectionDiagonal1(get, never):Mat3;

	static private function get_EdgeDetectionDiagonal1() {
		return new Mat3(0, -1, -1, -1, 4, -1, -1, -1, 0);
	}

	public static var EdgeDetectionDiagonal2(get, never):Mat3;

	static private function get_EdgeDetectionDiagonal2() {
		return new Mat3(-1, -1, 0, -1, 4, -1, 0, -1, -1);
	}

	public static var Emboss(get, never):Mat3;

	static private function get_Emboss() {
		return new Mat3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	}

	public static var Laplacian(get, never):Mat3;

	static private function get_Laplacian() {
		return new Mat3(0, -1, 0, -1, 4, -1, 0, -1, 0);
	}

	public static var SobelVertical(get, never):Mat3;

	static private function get_SobelVertical() {
		return new Mat3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	}

	public static var SobelHorizontal(get, never):Mat3;

	static private function get_SobelHorizontal() {
		return new Mat3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	}

	public static var Outline(get, never):Mat3;

	static private function get_Outline() {
		return new Mat3(-1, -1, -1, -1, 8, -1, -1, -1, -1);
	}

	public static var HighPass(get, never):Mat3;

	static private function get_HighPass() {
		return new Mat3(-1, -1, -1, -1, 9, -1, -1, -1, -1);
	}

	public static var RidgeDetection(get, never):Mat3;

	static private function get_RidgeDetection() {
		return new Mat3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	}

	public static var DepthEnhance(get, never):Mat3;

	static private function get_DepthEnhance() {
		return new Mat3(1, 1, 1, 1, -7, 1, 1, 1, 1);
	}

	public static var PrewittHorizontal(get, never):Mat3;

	static private function get_PrewittHorizontal() {
		return new Mat3(-1, -1, -1, 0, 0, 0, 1, 1, 1);
	}

	public static var PrewittVertical(get, never):Mat3;

	static private function get_PrewittVertical() {
		return new Mat3(-1, 0, 1, -1, 0, 1, -1, 0, 1);
	}

	public static var Identity(get, never):Mat3;

	static private function get_Identity() {
		return new Mat3(0, 0, 0, 0, 1, 0, 0, 0, 0);
	}
}
