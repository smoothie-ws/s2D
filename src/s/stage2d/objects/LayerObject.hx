package s.stage2d.objects;

abstract class LayerObject extends StageObject {
	public var layer(default, set):StageLayer;

	public function addToLayer(layer:StageLayer) {
		this.layer = layer;
	}

	abstract function set_layer(value:StageLayer):StageLayer;
}
