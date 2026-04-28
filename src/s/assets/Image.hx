package s.assets;

import haxe.io.Bytes;
import s.graphics.TextureParameters;
import s.assets.internal.image.Image as Internal;

@:forward()
@:forward.new
@:build(s.macro.AssetsMacro.buildAssetType("Image"))
abstract Image(Internal) from Internal to Internal {
	public static inline function fromBytes(bytes:Bytes, width:Int, height:Int, ?format:TextureFormat)
		return fromResource(kha.Image.fromBytes(bytes, width, height, format));
}
