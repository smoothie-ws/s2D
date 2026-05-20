package s;

import s.math.Vec2;
import s.math.Mat3;

abstract class Object2D<T:Object2D<T>> extends Object<T> {
	@:attr(transformLocal) final transform:Mat3 = new Mat3();
	var localScaleX:Float = 1.0;
	var localScaleY:Float = 1.0;
	var localRotation:Float = 0.0;
	var localShearX:Float = 0.0;
	var localShearY:Float = 0.0;

	public var translationX(get, set):Float;
	public var translationY(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var rotation(get, set):Float;
	public var shearX(get, set):Float;
	public var shearY(get, set):Float;

	@:attr(hierarchy) public var z:Float = 0.0;

	extern overload public inline function setTranslation(value:Vec2)
		setTranslation(value.x, value.y);

	extern overload public inline function setTranslation(x:Float, y:Float) {
		translationX = x;
		translationY = y;
	}

	extern overload public inline function setScale(value:Vec2)
		setScale(value.x, value.y);

	extern overload public inline function setScale(x:Float, y:Float) {
		scaleX = x;
		scaleY = y;
	}

	extern overload public inline function setRotation(value:Float)
		rotation = value;

	extern overload public inline function setShear(value:Vec2)
		setShear(value.x, value.y);

	extern overload public inline function setShear(x:Float, y:Float) {
		shearX = x;
		shearY = y;
	}

	extern overload public inline function translate(value:Vec2)
		translate(value.x, value.y);

	extern overload public inline function translate(value:Float)
		translate(value, value);

	extern overload public inline function translate(x:Float, y:Float) {
		transform._20 += x;
		transform._21 += y;
		transformDirty = true;
	}

	extern overload public inline function scale(x:Float, y:Float) {
		localScaleX *= x;
		localShearX *= x;
		localShearY *= y;
		localScaleY *= y;
		updateLinear();
		transformDirty = true;
	}

	extern overload public inline function scale(value:Vec2)
		scale(value.x, value.y);

	extern overload public inline function scale(value:Float)
		scale(value, value);

	extern overload public inline function rotate(value:Float) {
		var c = Math.cos(value);
		var s = Math.sin(value);
		var sx = localScaleX;
		var shx = localShearX;
		var shy = localShearY;
		var sy = localScaleY;
		localScaleX = sx * c + shy * s;
		localShearX = shx * c + sy * s;
		localShearY = -sx * s + shy * c;
		localScaleY = -shx * s + sy * c;
		updateLinear();
		transformDirty = true;
	}

	extern overload public inline function shear(x:Float, y:Float) {
		var sx = localScaleX;
		var shx = localShearX;
		var shy = localShearY;
		var sy = localScaleY;
		localScaleX = sx + shy * x;
		localShearX = shx + sy * x;
		localShearY = sx * y + shy;
		localScaleY = shx * y + sy;
		updateLinear();
		transformDirty = true;
	}

	extern overload public inline function shear(value:Vec2)
		shear(value.x, value.y);

	function insertChild(child:T) {
		var list = @:privateAccess children.list;
		var ind = list.indexOf(child);

		list.remove(child);
		var lower = list.length;
		var upper = list.length;
		for (i in 0...list.length) {
			if (lower == list.length && list[i].z >= child.z)
				lower = i;
			if (list[i].z > child.z) {
				upper = i;
				break;
			}
		}

		var target = upper;
		if (ind >= 0) {
			if (ind < lower)
				target = lower;
			else if (upper < ind)
				target = upper;
			else
				target = ind;
		}
		list.insert(target, child);

		if (ind != list.indexOf(child))
			children.dirty = true;
	}

	inline function get_translationX():Float
		return transform._20;

	inline function set_translationX(value:Float) {
		transformDirty = true;
		return transform._20 = value;
	}

	inline function get_translationY():Float
		return transform._21;

	inline function set_translationY(value:Float) {
		transformDirty = true;
		return transform._21 = value;
	}

	inline function get_scaleX():Float
		return localScaleX;

	inline function set_scaleX(value:Float) {
		transformDirty = true;
		localScaleX = value;
		updateLinear();
		return localScaleX;
	}

	inline function get_scaleY():Float
		return localScaleY;

	inline function set_scaleY(value:Float) {
		transformDirty = true;
		localScaleY = value;
		updateLinear();
		return localScaleY;
	}

	inline function get_rotation():Float
		return localRotation;

	inline function set_rotation(value:Float) {
		transformDirty = true;
		localRotation = value;
		updateLinear();
		return localRotation;
	}

	inline function get_shearX():Float
		return localShearX;

	inline function set_shearX(value:Float) {
		transformDirty = true;
		localShearX = value;
		updateLinear();
		return localShearX;
	}

	inline function get_shearY():Float
		return localShearY;

	inline function set_shearY(value:Float) {
		transformDirty = true;
		localShearY = value;
		updateLinear();
		return localShearY;
	}

	inline function updateLinear() {
		var c = Math.cos(localRotation);
		var s = Math.sin(localRotation);

		transform._00 = c * localScaleX - s * localShearX;
		transform._10 = s * localScaleX + c * localShearX;
		transform._01 = c * localShearY - s * localScaleY;
		transform._11 = s * localShearY + c * localScaleY;
	}
}
