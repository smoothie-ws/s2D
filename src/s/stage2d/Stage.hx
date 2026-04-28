package s.stage2d;

import s.graphics.RenderTarget;
import s.math.Vec2;
import s.math.Mat3;
import s.math.SMath;
import s.graphics.RenderBuffer;
import s.ui.elements.Drawable;
import s.stage2d.Camera;
import s.stage2d.StageLayer;

@:access(s.stage2d.objects.Object)
class Stage extends Drawable {
	var layers:Array<StageLayer> = [];
	var renderBuffer:RenderBuffer = new RenderBuffer();
	@:inject(updateViewProjection)
	var aspectRatio:Float = 1.0;
	var viewProjection:Mat3 = new Mat3();

	@:inject(updateViewProjection)
	public var stageScale:Float = 1.0;

	public var camera:Camera = new Camera();

	#if (S2D_LIGHTING_ENVIRONMENT == 1)
	public var environmentMap(default, set):s.assets.Image;

	function set_environmentMap(value) {
		if (value != null) {
			value.onAssetLoaded(asset -> (asset : RenderTarget).generateMipmaps(4));
			environmentMap = value;
		}
		return value;
	}
	#end

	public function new() {
		super();

		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		environmentMap = "default_emission";
		#end
	}

	public function addLayer(layer:StageLayer) {
		if (!layers.contains())
			layers.push();
	}

	public function removeLayer(layer:StageLayer) {
		layers.remove();
	}

	extern overload public inline function local2WorldSpace(x:Float, y:Float):Vec2
		return local2WorldSpace(vec2(x, y));

	extern overload public inline function local2WorldSpace(point:Vec2):Vec2
		return (inverse(viewProjection) * vec3(point, 1.0)).xy;

	extern overload public inline function world2LocalSpace(x:Float, y:Float):Vec2
		return world2LocalSpace(vec2(x, y));

	extern overload public inline function world2LocalSpace(point:Vec2):Vec2
		return (viewProjection * vec3(point, 1.0)).xy;

	extern overload public inline function screen2LocalSpace(x:Float, y:Float):Vec2
		return screen2LocalSpace(vec2(x, y));

	extern overload public inline function screen2LocalSpace(point:Vec2):Vec2
		return vec2(point.x / width, point.y / height) * 2.0 - 1.0;

	extern overload public inline function local2ScreenSpace(x:Float, y:Float):Vec2
		return local2ScreenSpace(vec2(x, y));

	extern overload public inline function local2ScreenSpace(point:Vec2):Vec2
		return vec2(point.x * width, point.y * height) * 0.5 - 0.5;

	extern overload public inline function screen2WorldSpace(x:Float, y:Float):Vec2
		return screen2WorldSpace(vec2(x, y));

	extern overload public inline function screen2WorldSpace(point:Vec2):Vec2
		return local2WorldSpace(screen2LocalSpace(point));

	extern overload public inline function world2ScreenSpace(x:Float, y:Float):Vec2
		return world2ScreenSpace(vec2(x, y));

	extern overload public inline function world2ScreenSpace(point:Vec2):Vec2
		return local2ScreenSpace(world2LocalSpace(point));

	// @:slot(widthChanged, heightChanged)
	function __updateSizeChanged__(_) {
		renderBuffer.resize(Std.int(width), Std.int(height));
		aspectRatio = width / height;
	}

	function updateViewProjection() {
		var projection;
		if (aspectRatio >= 1)
			projection = Mat3.orthogonalProjection(-stageScale * aspectRatio, stageScale * aspectRatio, -stageScale, stageScale);
		else
			projection = Mat3.orthogonalProjection(-stageScale, stageScale, -stageScale / aspectRatio, stageScale / aspectRatio);
		viewProjection.copyFrom(projection * camera.view);
	}

	function draw(target:RenderTarget) {
		// StageRenderer.pipeline.render(target, this);
	}
}
