package s.stage2d.objects;

#if (S2D_LIGHTING == 1)
import s.Color;

class Light extends LayerObject {
	public var color:Color = "white";
	public var power:Float = 15.0;
	public var radius:Float = 1.0;
	#if (S2D_LIGHTING_SHADOWS == 1)
	public var isMappingShadows:Bool = false;
	#end

	public function new(?layer:StageLayer) {
		super();
	}

	function set_layer(value:StageLayer):StageLayer {
		if (value != layer) {
			if (layer != null && layer.lights.contains(this))
				layer.lights.remove(this);
			if (value != null && !value.lights.contains(this))
				value.lights.push(this);
			layer = value;
		}
		return layer;
	}
}
#end
