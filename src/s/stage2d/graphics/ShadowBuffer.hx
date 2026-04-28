package s.stage2d.graphics;

#if (S2D_LIGHTING_SHADOWS == 1)
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import s.math.Vec2;
import s.math.Mat3;
import s.math.SMath;
import s.stage2d.objects.Sprite;
import s.stage2d.graphics.lighting.ShadowPass;

@:dox(hide)
class ShadowBuffer {
	var indices:IndexBuffer;
	var vertices:VertexBuffer;
	var sprites:Array<Sprite> = [];

	public function new() {
		ShadowPass.compile();
		indices = new IndexBuffer(0, StaticUsage);
		vertices = new VertexBuffer(0, @:privateAccess ShadowPass.structure, DynamicUsage);
	}

	function addSprite(sprite:Sprite) @:privateAccess {
		if (sprite.mesh.length > 0) {
			sprites.push(sprite);
			updateBuffers();
		}
	}

	function removeSprite(sprite:Sprite) {
		if (sprite.mesh.length > 0) {
			sprites.remove(sprite);
			updateBuffers();
		}
	}

	function updateBuffersData() @:privateAccess {
		final structSize = @:privateAccess ShadowPass.structure.byteSize() >> 2;
		var vert = vertices.lock();
		var offset = 0;
		for (sprite in sprites) {
			for (v in sprite.mesh) {
				var p:Vec2 = sprite.transform * v;
				// start
				vert[offset + 0] = p.x;
				vert[offset + 1] = p.y;
				vert[offset + 2] = sprite.z;
				vert[offset + 3] = 0.0;
				vert[offset + 4] = sprite.shadowOpacity;
				offset += structSize;
				// end
				vert[offset + 0] = p.x;
				vert[offset + 1] = p.y;
				vert[offset + 2] = sprite.z;
				vert[offset + 3] = 1.0;
				vert[offset + 4] = sprite.shadowOpacity;
				offset += structSize;
			}
		}
		vertices.unlock();
	}

	function updateBuffers() {
		var vertexCount = 0;
		for (sprite in sprites)
			#if (S2D_LIGHTING_SHADOWS_SOFT == 1)
			vertexCount += sprite.mesh.length * 3;
			#else
			vertexCount += sprite.mesh.length * 2;
			#end
		// update vertices
		vertices.delete();
		vertices = new VertexBuffer(vertexCount, @:privateAccess ShadowPass.structure, DynamicUsage);
		// update indices
		indices.delete();
		#if (S2D_LIGHTING_SHADOWS_SOFT == 1)
		indices = new IndexBuffer(vertexCount * 2, StaticUsage);
		final ind = indices.lock();
		var vo = 0;
		for (sprite in sprites) {
			final l = sprite.mesh.length * 2;
			var vc = 0;
			for (_ in sprite.mesh) {
				final io = (vo + vc) * 3;
				// e1 -> e2 -> p1
				ind[io + 0] = vo + (vc + 0) % l;
				ind[io + 1] = vo + (vc + 1) % l;
				ind[io + 2] = vo + (vc + 2) % l;
				// e2 -> p2 -> e1
				ind[io + 3] = vo + (vc + 3) % l;
				ind[io + 4] = vo + (vc + 2) % l;
				ind[io + 5] = vo + (vc + 1) % l;
				vc += 2;
			}
			vo += vc;
		}
		indices.unlock();
		#else
		indices = new IndexBuffer(vertexCount * 3, StaticUsage);
		final ind = indices.lock();
		var vo = 0;
		for (sprite in sprites) {
			final l = sprite.mesh.length * 2;
			var vc = 0;
			for (_ in sprite.mesh) {
				final io = (vo + vc) * 3;
				// p1 -> e1 -> p2
				ind[io + 0] = vo + (vc + 0) % l;
				ind[io + 1] = vo + (vc + 1) % l;
				ind[io + 2] = vo + (vc + 2) % l;
				// e2 -> p2 -> e1
				ind[io + 3] = vo + (vc + 3) % l;
				ind[io + 4] = vo + (vc + 2) % l;
				ind[io + 5] = vo + (vc + 1) % l;
				vc += 2;
			}
			vo += vc;
		}
		indices.unlock();
		#end
	}
}
#end
