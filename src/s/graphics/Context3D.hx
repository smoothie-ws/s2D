package s.graphics;

import kha.arrays.Float32Array;
import kha.arrays.Int32Array;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import s.math.Mat3;
import s.math.Mat4;
import s.math.SMath;
import s.math.Vec2;
import s.math.IVec2;
import s.math.Vec3;
import s.math.IVec3;
import s.math.Vec4;
import s.math.IVec4;
import s.assets.Image;
import s.geometry.Mesh;
import s.graphics.TextureUnit;
import s.graphics.ConstantLocation;
import s.graphics.TextureParameters;

private final logger:Log.Logger = new Log.Logger("RENDER");

enum DrawCommand {
	Clear(color:Color, depth:Float, stencil:Int);
	Scissor(x:Int, y:Int, width:Int, height:Int);
	DisableScissor;
	ConstantBool(location:ConstantLocation, value:Bool);
	ConstantInt(location:ConstantLocation, value:Int);
	ConstantInts(location:ConstantLocation, value:Int32Array);
	ConstantIVec2(location:ConstantLocation, value:IVec2);
	ConstantIVec3(location:ConstantLocation, value:IVec3);
	ConstantIVec4(location:ConstantLocation, value:IVec4);
	ConstantFloat(location:ConstantLocation, value:Float);
	ConstantFloats(location:ConstantLocation, value:Float32Array);
	ConstantVec2(location:ConstantLocation, value:Vec2);
	ConstantVec3(location:ConstantLocation, value:Vec3);
	ConstantVec4(location:ConstantLocation, value:Vec4);
	ConstantMat3(location:ConstantLocation, value:Mat3);
	ConstantMat4(location:ConstantLocation, value:Mat4);
	ConstantTexture(unit:TextureUnit, image:Image);
	ConstantTextureParameters(unit:TextureUnit, parameters:TextureParameters);
}

private typedef DrawStep = {
	var pipeline:PipelineState;
	var start:Int;
	var count:Int;
	var ?instanceCount:Int;
	var commandStart:Int;
	var commandCount:Int;
}

private typedef DrawState = {
	var inputLayout:Array<VertexStructure>;
	var usesExternalVertexBuffers:Bool;
	var ?mesh:Mesh;
	var meshPolygonCount:Int;
	var meshIndexCount:Int;
	var meshDirty:Bool;
	var ?indexBuffer:IndexBuffer;
	var ?vertexBuffer:VertexBuffer;
	var ?vertexBuffers:Array<VertexBuffer>;
	var steps:Array<DrawStep>;
	var usedSteps:Int;
	var commands:Array<DrawCommand>;
	var usedCommands:Int;
}

private typedef DrawStateBuffer = {
	var stateId:Int;
	var commands:Array<DrawCommand>;
	var meshIndexCount:Int;
	var reusableGeometry:Bool;
	var pendingDraw:Bool;
	var ?pipeline:PipelineState;
	var ?mesh:Mesh;
	var ?vertexBuffers:Array<VertexBuffer>;
}

@:allow(s.graphics.RenderTarget)
class Context3D {
	final graphics:Graphics;
	final owner:RenderTarget;
	final states:Array<DrawState> = [];

	var targets:Array<kha.Canvas>;
	var buffer:DrawStateBuffer;
	var fallbackQuadIndexBuffer:IndexBuffer;

	#if debug
	public static var drawCalls(default, null):Int = 0;
	public static var ibAllocations(default, null):Int = 0;
	public static var vbAllocations(default, null):Int = 0;

	public static function resetDebugInfo() {
		drawCalls = 0;
		ibAllocations = 0;
		vbAllocations = 0;
	}
	#end

	public final vsynced:Bool;
	public final refreshRate:Int;
	public final instancedRenderingAvailable:Bool;

	function new(graphics:Graphics, owner:RenderTarget) {
		this.graphics = graphics;
		this.owner = owner;
		vsynced = graphics.vsynced();
		refreshRate = graphics.refreshRate();
		instancedRenderingAvailable = graphics.instancedRenderingAvailable();
		buffer = emptyBuffer(0);
	}

	inline function emptyBuffer(stateId:Int):DrawStateBuffer
		return {
			stateId: stateId,
			meshIndexCount: 0,
			reusableGeometry: false,
			pendingDraw: false,
			commands: []
		};

	inline function applyCommand(command:DrawCommand) {
		switch command {
			case Clear(color, depth, stencil):
				graphics.clear(color, owner?.hasDepthAttachment ? depth : null, owner?.hasStencilAttachment ? stencil : null);
			case Scissor(x, y, width, height):
				graphics.scissor(x, y, width, height);
			case DisableScissor:
				graphics.disableScissor();
			case ConstantBool(location, value):
				graphics.setBool(location, value);
			case ConstantInt(location, value):
				graphics.setInt(location, value);
			case ConstantInts(location, value):
				graphics.setInts(location, value);
			case ConstantIVec2(location, value):
				graphics.setInt2(location, value.x, value.y);
			case ConstantIVec3(location, value):
				graphics.setInt3(location, value.x, value.y, value.z);
			case ConstantIVec4(location, value):
				graphics.setInt4(location, value.x, value.y, value.z, value.w);
			case ConstantFloat(location, value):
				graphics.setFloat(location, value);
			case ConstantFloats(location, value):
				graphics.setFloats(location, value);
			case ConstantVec2(location, value):
				graphics.setVector2(location, value);
			case ConstantVec3(location, value):
				graphics.setVector3(location, value);
			case ConstantVec4(location, value):
				graphics.setVector4(location, value);
			case ConstantMat3(location, value):
				graphics.setMatrix3(location, value);
			case ConstantMat4(location, value):
				graphics.setMatrix(location, value);
			case ConstantTexture(unit, image):
				graphics.setTexture(unit, image);
			case ConstantTextureParameters(unit, parameters):
				graphics.setTextureParameters(unit, parameters.uAddressing, parameters.vAddressing, parameters.minificationFilter,
					parameters.magnificationFilter, parameters.mipmapFilter);
		}
	}

	function sameRefs<T>(a:Array<T>, b:Array<T>):Bool {
		if (a == b)
			return true;
		if (a == null || b == null || a.length != b.length)
			return false;
		for (i in 0...a.length)
			if (a[i] != b[i])
				return false;
		return true;
	}

	inline function inputLayoutsEqual(a:Array<VertexStructure>, b:Array<VertexStructure>):Bool
		return sameRefs(a, b);

	inline function vertexBuffersEqual(a:Array<VertexBuffer>, b:Array<VertexBuffer>):Bool
		return sameRefs(a, b);

	inline function meshIndexCount(mesh:Mesh):Int {
		if (mesh == null)
			return 0;

		var count = 0;
		for (polygon in mesh)
			if (polygon.length >= 3)
				count += (polygon.length - 2) * 3;
		return count;
	}

	inline function resetGeneratedBuffers(state:DrawState) {
		state.vertexBuffer?.delete();
		state.indexBuffer?.delete();
		state.vertexBuffer = null;
		state.indexBuffer = null;
		state.meshDirty = true;
	}

	inline function ensureFallbackQuadIndexBuffer() {
		if (fallbackQuadIndexBuffer != null)
			return;

		fallbackQuadIndexBuffer = new IndexBuffer(6, StaticUsage);
		final data = fallbackQuadIndexBuffer.lock(0, 6);
		data[0] = 0;
		data[1] = 1;
		data[2] = 2;
		data[3] = 0;
		data[4] = 2;
		data[5] = 3;
		fallbackQuadIndexBuffer.unlock(6);

		#if debug
		++ ibAllocations;
		#end
	}

	inline function createState(inputLayout:Array<VertexStructure>, usesExternalVertexBuffers:Bool, vertexBuffers:Array<VertexBuffer>):DrawState
		return {
			inputLayout: inputLayout,
			usesExternalVertexBuffers: usesExternalVertexBuffers,
			mesh: usesExternalVertexBuffers ? null : [],
			meshPolygonCount: 0,
			meshIndexCount: 0,
			meshDirty: true,
			vertexBuffers: vertexBuffers,
			steps: [],
			usedSteps: 0,
			commands: [],
			usedCommands: 0
		};

	function stateCompatible(state:DrawState, inputLayout:Array<VertexStructure>, usesExternalVertexBuffers:Bool, vertexBuffers:Array<VertexBuffer>):Bool {
		if (state == null)
			return false;
		if (state.usesExternalVertexBuffers != usesExternalVertexBuffers)
			return false;
		if (!inputLayoutsEqual(state.inputLayout, inputLayout))
			return false;
		return !usesExternalVertexBuffers || vertexBuffersEqual(state.vertexBuffers, vertexBuffers);
	}

	function openState(stateId:Int, inputLayout:Array<VertexStructure>, usesExternalVertexBuffers:Bool, vertexBuffers:Array<VertexBuffer>):DrawState {
		var state:DrawState;

		if (stateId == states.length) {
			state = createState(inputLayout, usesExternalVertexBuffers, vertexBuffers);
			states.push(state);
		} else {
			state = states[stateId];
			if (!stateCompatible(state, inputLayout, usesExternalVertexBuffers, vertexBuffers)) {
				resetGeneratedBuffers(state);
				state.inputLayout = inputLayout;
				state.usesExternalVertexBuffers = usesExternalVertexBuffers;
				state.vertexBuffers = vertexBuffers;
				state.steps.resize(0);
				if (usesExternalVertexBuffers)
					state.mesh = null;
				else if (state.mesh == null)
					state.mesh = [];
			} else
				state.vertexBuffers = vertexBuffers;
		}

		state.usedSteps = 0;
		state.usedCommands = 0;
		state.meshPolygonCount = 0;
		state.meshIndexCount = 0;
		state.meshDirty = false;
		if (usesExternalVertexBuffers)
			state.mesh = null;
		else if (state.mesh == null)
			state.mesh = [];

		return state;
	}

	function appendMeshChunk(state:DrawState, mesh:Mesh) {
		if (mesh == null || mesh.length == 0)
			return;

		final target = state.mesh;
		for (polygon in mesh) {
			final index = state.meshPolygonCount++;
			if (index < target.length) {
				if (target[index] != polygon) {
					target[index] = polygon;
					state.meshDirty = true;
				}
			} else {
				target.push(polygon);
				state.meshDirty = true;
			}

			if (polygon.length >= 3)
				state.meshIndexCount += (polygon.length - 2) * 3;
		}
	}

	function findBinding<T:{unit:TextureUnit}>(entries:Array<T>, unit:TextureUnit):T {
		for (entry in entries)
			if (entry.unit == unit)
				return entry;
		return null;
	}

	function finalizeState(state:DrawState) {
		if (state == null)
			return;

		if (state.steps.length != state.usedSteps)
			state.steps.resize(state.usedSteps);
		if (state.commands.length != state.usedCommands)
			state.commands.resize(state.usedCommands);

		if (!state.usesExternalVertexBuffers && state.mesh != null && state.mesh.length != state.meshPolygonCount) {
			state.mesh.resize(state.meshPolygonCount);
			state.meshDirty = true;
		}
	}

	function bakeState(state:DrawState) {
		if (state == null || state.usesExternalVertexBuffers)
			return;

		if (state.inputLayout == null || state.inputLayout.length == 0 || state.mesh == null || state.mesh.length == 0) {
			resetGeneratedBuffers(state);
			return;
		}

		if (!state.meshDirty && state.vertexBuffer != null && state.indexBuffer != null)
			return;

		final structure = state.inputLayout[0];

		var indexCount = 0;
		var vertexCount = 0;
		for (polygon in state.mesh) {
			vertexCount += polygon.length;
			if (polygon.length >= 3)
				indexCount += (polygon.length - 2) * 3;
		}

		if (vertexCount == 0 || indexCount == 0) {
			resetGeneratedBuffers(state);
			return;
		}

		if (state.vertexBuffer == null || vertexCount > state.vertexBuffer.count()) {
			state.vertexBuffer?.delete();
			state.vertexBuffer = new VertexBuffer(vertexCount, structure, StaticUsage);

			#if debug
			++ vbAllocations;
			#end
		}

		if (state.indexBuffer == null || indexCount > state.indexBuffer.count()) {
			state.indexBuffer?.delete();
			state.indexBuffer = new IndexBuffer(indexCount, StaticUsage);

			#if debug
			++ ibAllocations;
			#end
		}

		final indices = state.indexBuffer.lock(0, indexCount);
		final vertices = state.vertexBuffer.lock(0, vertexCount);

		var indexOffset = 0;
		var vertexOffset = 0;
		var baseVertex = 0;

		for (polygon in state.mesh) {
			if (polygon.length >= 3)
				for (i in 1...polygon.length - 1) {
					indices[indexOffset++] = baseVertex;
					indices[indexOffset++] = baseVertex + i;
					indices[indexOffset++] = baseVertex + i + 1;
				}

			baseVertex += polygon.length;

			for (vertex in polygon)
				for (value in vertex)
					vertices[vertexOffset++] = value;
		}

		state.indexBuffer.unlock(indexCount);
		state.vertexBuffer.unlock(vertexCount);
		state.meshDirty = false;
	}

	inline function resolveDrawCount(meshIndexCount:Int, start:Int, count:Int):Int {
		if (count >= 0)
			return count;
		if (meshIndexCount > 0)
			return Std.int(Math.max(0, meshIndexCount - start));
		return Std.int(Math.max(0, 6 - start));
	}

	function appendCommands(state:DrawState, commands:Array<DrawCommand>):{start:Int, count:Int} {
		if (commands == null || commands.length == 0)
			return {start: state.usedCommands, count: 0};

		final start = state.usedCommands;
		for (command in commands)
			if (state.usedCommands == state.commands.length) {
				state.commands.push(command);
				state.usedCommands++;
			} else
				state.commands[state.usedCommands++] = command;

		return {start: start, count: commands.length};
	}

	function appendStep(state:DrawState, pipeline:PipelineState, start:Int, count:Int, instanceCount:Null<Int>, commands:Array<DrawCommand>) {
		final stepIndex = state.usedSteps++;
		final commandRange = appendCommands(state, commands);
		final step:DrawStep = {
			pipeline: pipeline,
			start: start,
			count: count,
			instanceCount: instanceCount,
			commandStart: commandRange.start,
			commandCount: commandRange.count
		};

		if (stepIndex == state.steps.length)
			state.steps.push(step);
		else
			state.steps[stepIndex] = step;
	}

	function nextBufferAfterCommit(stateId:Int, previous:DrawStateBuffer):DrawStateBuffer {
		final next = emptyBuffer(stateId);
		next.pipeline = previous.pipeline;
		if (previous.reusableGeometry) {
			next.mesh = previous.mesh;
			next.meshIndexCount = previous.meshIndexCount;
			next.vertexBuffers = previous.vertexBuffers;
			next.reusableGeometry = true;
		}
		return next;
	}

	function commit(instanceCount:Null<Int>, start:Int, count:Int) {
		if (buffer.pipeline == null)
			return;

		final inputLayout = buffer.pipeline.inputLayout;
		if (inputLayout == null || inputLayout.length == 0)
			return;

		final usesExternalVertexBuffers = buffer.vertexBuffers != null;
		var stateId = buffer.stateId;
		var state = stateId > 0 ? states[stateId - 1] : null;

		if (!stateCompatible(state, inputLayout, usesExternalVertexBuffers, buffer.vertexBuffers)) {
			state = openState(stateId, inputLayout, usesExternalVertexBuffers, buffer.vertexBuffers);
			stateId++;
		}

		var drawStart = start;
		if (!usesExternalVertexBuffers) {
			drawStart += state.meshIndexCount;
			appendMeshChunk(state, buffer.mesh);
		}

		appendStep(state, buffer.pipeline, drawStart, resolveDrawCount(buffer.meshIndexCount, start, count), instanceCount, buffer.commands);
		buffer = nextBufferAfterCommit(stateId, buffer);
	}

	inline function hasPendingDraw():Bool
		return buffer.pendingDraw && buffer.pipeline != null && (buffer.mesh != null && buffer.meshIndexCount > 0 || buffer.vertexBuffers != null
			&& buffer.vertexBuffers.length > 0);

	public inline function reset(?mrt:Array<kha.Canvas>) {
		targets = mrt;
		buffer = emptyBuffer(0);
	}

	public inline function begin(?mrt:Array<kha.Canvas>)
		reset(mrt);

	function executePendingCommands() {
		if (buffer.commands == null || buffer.commands.length == 0 || buffer.pipeline != null || buffer.mesh != null || buffer.vertexBuffers != null)
			return;

		for (command in buffer.commands)
			switch command {
				case Clear(_, _, _) | Scissor(_, _, _, _) | DisableScissor:
					applyCommand(command);
				case _:
			}
	}

	public inline function execute() {
		try {
			for (i in 0...buffer.stateId)
				finalizeState(states[i]);

			graphics.begin(targets);
			executePendingCommands();

			var boundTextures:Array<{unit:TextureUnit, image:Image}> = [];
			var boundTextureParams:Array<{unit:TextureUnit, parameters:TextureParameters}> = [];
			for (i in 0...buffer.stateId) {
				final state = states[i];
				if (state == null)
					continue;

				if (state.usesExternalVertexBuffers) {
					if (state.vertexBuffers == null || state.vertexBuffers.length == 0)
						continue;
					ensureFallbackQuadIndexBuffer();
					graphics.setIndexBuffer(fallbackQuadIndexBuffer);
					graphics.setVertexBuffers(state.vertexBuffers);
				} else {
					bakeState(state);
					if (state.indexBuffer == null || state.vertexBuffer == null)
						continue;
					graphics.setIndexBuffer(state.indexBuffer);
					graphics.setVertexBuffer(state.vertexBuffer);
				}

				var currentPipeline:PipelineState = null;
				for (step in state.steps) {
					if (step == null || step.count <= 0 || step.pipeline == null)
						continue;

					if (currentPipeline != step.pipeline) {
						graphics.setPipeline(step.pipeline);
						currentPipeline = step.pipeline;
						boundTextures.resize(0);
						boundTextureParams.resize(0);
					}

					if (step.commandCount > 0)
						for (j in step.commandStart...step.commandStart + step.commandCount) {
							final command = state.commands[j];
							switch command {
								case ConstantTexture(unit, image):
									var entry = findBinding(boundTextures, unit);
									if (entry == null) {
										entry = {unit: unit, image: image};
										boundTextures.push(entry);
										graphics.setTexture(unit, image);
									} else if (entry.image != image) {
										entry.image = image;
										graphics.setTexture(unit, image);
									}

								case ConstantTextureParameters(unit, parameters):
									var entry = findBinding(boundTextureParams, unit);
									if (entry == null) {
										entry = {unit: unit, parameters: parameters};
										boundTextureParams.push(entry);
										graphics.setTextureParameters(unit, parameters.uAddressing, parameters.vAddressing, parameters.minificationFilter,
											parameters.magnificationFilter, parameters.mipmapFilter);
									} else if (entry.parameters != parameters) {
										entry.parameters = parameters;
										graphics.setTextureParameters(unit, parameters.uAddressing, parameters.vAddressing, parameters.minificationFilter,
											parameters.magnificationFilter, parameters.mipmapFilter);
									}

								case _:
									applyCommand(command);
							}
						}

					if (step.instanceCount != null)
						graphics.drawIndexedVerticesInstanced(step.instanceCount, step.start, step.count);
					else
						graphics.drawIndexedVertices(step.start, step.count);

					#if debug
					drawCalls++;
					#end
				}
			}

			graphics.end();
		} catch (e)
			logger.error("Failed: " + e.message);
	}

	public inline function end() {
		if (hasPendingDraw())
			draw();
		execute();
	}

	public inline function flush(?instanceCount:Int, start:Int = 0, count:Int = -1)
		commit(instanceCount, start, count);

	public inline function draw(start:Int = 0, count:Int = -1)
		commit(null, start, count);

	public inline function drawInstanced(instanceCount:Int, start:Int = 0, count:Int = -1)
		commit(instanceCount, start, count);

	public inline function setPipeline(pipeline:PipelineState) {
		buffer.pendingDraw = true;
		buffer.pipeline = pipeline;
	}

	public inline function setMesh(mesh:Mesh) {
		buffer.pendingDraw = true;
		buffer.mesh = mesh;
		buffer.meshIndexCount = meshIndexCount(mesh);
		buffer.vertexBuffers = null;
		buffer.reusableGeometry = true;
	}

	public inline function setVertexBuffers(vertexBuffers:Array<VertexBuffer>) {
		buffer.pendingDraw = true;
		buffer.vertexBuffers = vertexBuffers;
		buffer.mesh = null;
		buffer.meshIndexCount = 0;
		buffer.reusableGeometry = true;
	}

	inline function ensureBufferMesh() {
		if (buffer.mesh == null || buffer.reusableGeometry) {
			buffer.mesh = [];
			buffer.meshIndexCount = 0;
		}
		buffer.vertexBuffers = null;
		buffer.reusableGeometry = false;
	}

	public inline function addPolygon(p:Polygon) {
		buffer.pendingDraw = true;
		ensureBufferMesh();
		buffer.mesh.push(p);
		if (p != null && p.length >= 3)
			buffer.meshIndexCount += (p.length - 2) * 3;
	}

	public inline function addVertex(vertex:Vertex) {
		buffer.pendingDraw = true;
		ensureBufferMesh();
		if (buffer.mesh == null || buffer.mesh.length == 0)
			buffer.mesh = [[vertex]];
		else {
			buffer.mesh[buffer.mesh.length - 1].push(vertex);
			if (buffer.mesh[buffer.mesh.length - 1].length >= 3)
				buffer.meshIndexCount += 3;
		}
	}

	public inline function addCommand(command:DrawCommand, drawCommand:Bool = true) {
		if (drawCommand)
			buffer.pendingDraw = true;
		buffer.commands.push(command);
	}

	public inline function clear(?color:Color, ?depth:Float, ?stencil:Int)
		addCommand(Clear(color, depth, stencil), false);

	public inline function scissor(x:Int, y:Int, width:Int, height:Int)
		addCommand(Scissor(x, y, width, height), false);

	public inline function disableScissor()
		addCommand(DisableScissor, false);

	public inline function setBool(location:ConstantLocation, value:Bool)
		addCommand(ConstantBool(location, value));

	public inline function setInt(location:ConstantLocation, value:Int)
		addCommand(ConstantInt(location, value));

	public inline function setInts(location:ConstantLocation, value:Int32Array)
		addCommand(ConstantInts(location, value));

	extern overload public inline function setIVec2(location:ConstantLocation, value:IVec2)
		addCommand(ConstantIVec2(location, value));

	extern overload public inline function setIVec2(location:ConstantLocation, value1:Int, value2:Int)
		setIVec2(location, ivec2(value1, value2));

	extern overload public inline function setIVec3(location:ConstantLocation, value:IVec3)
		addCommand(ConstantIVec3(location, value));

	extern overload public inline function setIVec3(location:ConstantLocation, value1:Int, value2:Int, value3:Int)
		setIVec3(location, ivec3(value1, value2, value3));

	extern overload public inline function setIVec4(location:ConstantLocation, value:IVec4)
		addCommand(ConstantIVec4(location, value));

	extern overload public inline function setIVec4(location:ConstantLocation, value1:Int, value2:Int, value3:Int, value4:Int)
		setIVec4(location, ivec4(value1, value2, value3, value4));

	public inline function setFloat(location:ConstantLocation, value:Float)
		addCommand(ConstantFloat(location, value));

	public inline function setFloats(location:ConstantLocation, value:Float32Array)
		addCommand(ConstantFloats(location, value));

	extern overload public inline function setVec2(location:ConstantLocation, value:Vec2)
		addCommand(ConstantVec2(location, value));

	extern overload public inline function setVec2(location:ConstantLocation, value1:Float, value2:Float)
		setVec2(location, vec2(value1, value2));

	extern overload public inline function setVec3(location:ConstantLocation, value:Vec3)
		addCommand(ConstantVec3(location, value));

	extern overload public inline function setVec3(location:ConstantLocation, value1:Float, value2:Float, value3:Float)
		setVec3(location, vec3(value1, value2, value3));

	extern overload public inline function setVec4(location:ConstantLocation, value:Vec4)
		addCommand(ConstantVec4(location, value));

	extern overload public inline function setVec4(location:ConstantLocation, value1:Float, value2:Float, value3:Float, value4:Float)
		setVec4(location, vec4(value1, value2, value3, value4));

	extern overload public inline function setMat3(location:ConstantLocation, value:Mat3)
		addCommand(ConstantMat3(location, value));

	extern overload public inline function setMat3(location:ConstantLocation, value1:Vec3, value2:Vec3, value3:Vec3)
		setMat3(location, mat3(value1, value2, value3));

	extern overload public inline function setMat3(location:ConstantLocation, a00:Float, a10:Float, a20:Float, a01:Float, a11:Float, a21:Float, a02:Float,
			a12:Float, a22:Float)
		setMat3(location, mat3(a00, a10, a20, a01, a11, a21, a02, a12, a22));

	extern overload public inline function setMat4(location:ConstantLocation, value:Mat4)
		addCommand(ConstantMat4(location, value));

	extern overload public inline function setMat4(location:ConstantLocation, value1:Vec4, value2:Vec4, value3:Vec4, value4:Vec4)
		setMat4(location, mat4(value1, value2, value3, value4));

	extern overload public inline function setMat4(location:ConstantLocation, a00:Float, a10:Float, a20:Float, a30:Float, a01:Float, a11:Float, a21:Float,
			a31:Float, a02:Float, a12:Float, a22:Float, a32:Float, a03:Float, a13:Float, a23:Float, a33:Float)
		setMat4(location, mat4(a00, a10, a20, a30, a01, a11, a21, a31, a02, a12, a22, a32, a03, a13, a23, a33));

	extern overload public inline function setTexture(unit:TextureUnit, texture:Image)
		addCommand(ConstantTexture(unit, texture));

	extern overload public inline function setTexture(unit:TextureUnit, texture:Image, parameters:TextureParameters) {
		setTexture(unit, texture);
		setTextureParameters(unit, parameters);
	}

	extern overload public inline function setTexture(unit:TextureUnit, texture:Image, ?uAddressing:TextureAddressing, ?vAddressing:TextureAddressing,
			?minificationFilter:TextureFilter, ?magnificationFilter:TextureFilter, ?mipmapFilter:MipMapFilter) {
		setTexture(unit, texture);
		setTextureParameters(unit, uAddressing, vAddressing, minificationFilter, magnificationFilter, mipmapFilter);
	}

	overload extern public inline function setTextureParameters(unit:TextureUnit, ?uAddressing:TextureAddressing, ?vAddressing:TextureAddressing,
			?minificationFilter:TextureFilter, ?magnificationFilter:TextureFilter, ?mipmapFilter:MipMapFilter)
		setTextureParameters(unit, {
			uAddressing: uAddressing,
			vAddressing: vAddressing,
			minificationFilter: minificationFilter,
			magnificationFilter: magnificationFilter,
			mipmapFilter: mipmapFilter
		});

	overload extern public inline function setTextureParameters(unit:TextureUnit, parameters:TextureParameters)
		addCommand(ConstantTextureParameters(unit, parameters));
}
