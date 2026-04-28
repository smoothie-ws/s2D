package s.stage2d.objects;

import s.math.Vec2;
import s.geometry.Mesh;
import s.geometry.Rect;

using s.extensions.VectorExt;

class Sprite extends LayerObject {
	public var mesh:Mesh;
	public var cropRect:Rect = new Rect(0.0, 0.0, 1.0, 1.0);
	public var material(default, set):SpriteMaterial;

	#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
	public var isCastingShadows(default, set):Bool = false;
	public var shadowOpacity:Float = 1.0;

	function set_isCastingShadows(value:Bool) {
		if (!isCastingShadows && value)
			layer.shadowBuffer.addSprite(this);
		else if (isCastingShadows && !value)
			layer.shadowBuffer.removeSprite(this);
		isCastingShadows = value;
		return value;
	}
	#end

	function set_material(value:SpriteMaterial) {
		if (material != value) {
			#if (S2D_SPRITE_INSTANCING == 1)
			material.removeSprite(this);
			value.addSprite(this);
			#end
			material = value;
		}
		return value;
	}

	function set_layer(value:StageLayer):StageLayer {
		if (value != layer) {
			if (layer != null && layer.sprites.contains(this))
				layer.sprites.remove(this);
			if (value != null && !value.sprites.contains(this)) {
				value.sprites.push(this);
				if (!value.materials.contains(material))
					value.materials.push(material);
			}
			layer = value;
		}
		return layer;
	}
}
