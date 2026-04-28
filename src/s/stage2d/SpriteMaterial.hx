package s.stage2d;

#if (S2D_SPRITE_INSTANCING == 1)
import kha.graphics4.VertexBuffer;
#if (S2D_LIGHTING == 1)
import s.ui.graphics.StageRenderer;
#end
#end
import s.assets.ImageAsset;
import s.stage2d.objects.Sprite;

@:access(s.stage2d.objects.Sprite)
class SpriteMaterial {
	var sprites:Array<Sprite> = [];

	#if (S2D_LIGHTING == 1)
	public var albedoMap:ImageAsset;
	public var normalMap:ImageAsset;
	public var emissionMap:ImageAsset;
	#if (S2D_LIGHTING_PBR == 1)
	public var ormMap:ImageAsset;
	#end
	#else
	public var textureMap:ImageAsset;
	#end

	public function new() {
		#if (S2D_LIGHTING == 1)
		albedoMap = "default_color";
		normalMap = "default_normal";
		emissionMap = "default_emission";
		#if (S2D_LIGHTING_PBR == 1)
		ormMap = "default_orm";
		#end
		#else
		textureMap = "default_color";
		#end
		#if (S2D_SPRITE_INSTANCING == 1)
		init();
		#end
	}

	#if (S2D_SPRITE_INSTANCING == 1)
	var vertices:Array<VertexBuffer>;

	function deleteVertices() {
		for (i in 0...StageRenderer.structures.length)
			vertices[i].delete();
	}

	function initVertices() {
		vertices = [
			for (structure in StageRenderer.structures)
				new VertexBuffer(0, structure, StaticUsage, 1)
		];
	}

	function addSprite(sprite:Sprite) {
		sprites.push(sprite);
		deleteVertices();
		initVertices();
	}

	function update() {
		#if (S2D_LIGHTING == 1)
		final cStructSize = StageRenderer.structures[1].byteSize() >> 2;
		final mStructSize = StageRenderer.structures[2].byteSize() >> 2;
		final dStructSize = StageRenderer.structures[3].byteSize() >> 2;
		#end
		final cData = vertices[1].lock();
		final mData = vertices[2].lock();
		final dData = vertices[3].lock();
		for (i in 0...sprites.length) {
			final sprite = sprites[i];
			// crop rect
			final ci = i * cStructSize;
			cData[ci + 0] = sprite.cropRect.x;
			cData[ci + 1] = sprite.cropRect.y;
			cData[ci + 2] = sprite.cropRect.z;
			cData[ci + 3] = sprite.cropRect.w;
			// model
			final mi = i * mStructSize;
			mData[mi + 0] = sprite.transform._00;
			mData[mi + 1] = sprite.transform._01;
			mData[mi + 2] = sprite.transform._02;
			mData[mi + 3] = sprite.transform._10;
			mData[mi + 4] = sprite.transform._11;
			mData[mi + 5] = sprite.transform._12;
			mData[mi + 6] = sprite.transform._20;
			mData[mi + 7] = sprite.transform._21;
			mData[mi + 8] = sprite.transform._22;
			// depth
			final di = i * dStructSize;
			dData[di] = sprite.z;
		}
		vertices[1].unlock();
		vertices[2].unlock();
		vertices[3].unlock();
	}
	#end
}
