package s.stage2d;

import kha.arrays.Float32Array;
import s.stage2d.SpriteMaterial;
import s.stage2d.objects.Sprite;
#if (S2D_LIGHTING == 1)
import s.stage2d.objects.Light;
#if (S2D_LIGHTING_SHADOWS == 1)
import s.stage2d.graphics.ShadowBuffer;
#end
#end
class StageLayer {
	var stage:Stage;

	public var sprites:Array<Sprite> = [];
	public var materials:Array<SpriteMaterial> = [];

	public function new() {
		#if (S2D_LIGHTING)
		lightsBuffer = new Float32Array(1 + 4 * 8);
		#if (S2D_LIGHTING_SHADOWS == 1)
		shadowBuffer = new ShadowBuffer();
		#end
		#end
	}

	public function addSprite(sprite:Sprite) {
		sprite.layer = this;
	}

	public function removeSprite(sprite:Sprite) {
		sprite.layer = null;
	}

	#if (S2D_LIGHTING == 1)
	var lightsBuffer:Float32Array;
	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:ShadowBuffer;
	#end

	public var lights:Array<Light> = [];

	public function addLight(light:Light) {
		light.layer = this;
	}

	public function removeLight(light:Light) {
		light.layer = null;
	}

	function getLightsBuffer() {
		lightsBuffer[0] = lights.length;
		var offset = 1;
		for (light in lights) {
			lightsBuffer[offset++] = light.x;
			lightsBuffer[offset++] = light.y;
			lightsBuffer[offset++] = light.z;
			lightsBuffer[offset++] = light.color.r;
			lightsBuffer[offset++] = light.color.g;
			lightsBuffer[offset++] = light.color.b;
			lightsBuffer[offset++] = light.power;
			lightsBuffer[offset++] = light.radius;
		}
		return lightsBuffer;
	}
	#end
}
