package s.math;

#if macro
import haxe.macro.Expr.ExprOf;
#end
import kha.math.FastVector2 as KhaVec2;

@:nullSafety
@:forward.new
@:forward(x, y) #if !macro @:build(s.math.SMath.Swizzle.generateFields(2)) #end
extern abstract Vec2(KhaVec2) from KhaVec2 to KhaVec2 {
	#if !macro
	@:from
	public static inline function fromFloat(value:Float)
		return new Vec2(value, value);

	@:to
	public inline function toIVec2():IVec2
		return IVec2.fromVec2(this);

	public inline function set(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	public inline function clone()
		return new Vec2(this.x, this.y);

	public inline function setLength(value:Float):Float {
		var l = length();
		if (l == 0)
			return 0;
		var mul = value / l;
		this.x *= mul;
		this.y *= mul;
		return value;
	}

	// Trigonometric
	public inline function radians():Vec2
		return (this : Vec2) * Math.PI / 180;

	public inline function degrees():Vec2
		return (this : Vec2) * 180 / Math.PI;

	public inline function sin():Vec2
		return new Vec2(Math.sin(this.x), Math.sin(this.y));

	public inline function cos():Vec2
		return new Vec2(Math.cos(this.x), Math.cos(this.y));

	public inline function tan():Vec2
		return new Vec2(Math.tan(this.x), Math.tan(this.y));

	public inline function asin():Vec2
		return new Vec2(Math.asin(this.x), Math.asin(this.y));

	public inline function acos():Vec2
		return new Vec2(Math.acos(this.x), Math.acos(this.y));

	public inline function atan():Vec2
		return new Vec2(Math.atan(this.x), Math.atan(this.y));

	public inline function atan2(b:Vec2):Vec2
		return new Vec2(Math.atan2(this.x, b.x), Math.atan2(this.y, b.y));

	// Exponential
	public inline function pow(e:Vec2):Vec2
		return new Vec2(Math.pow(this.x, e.x), Math.pow(this.y, e.y));

	public inline function exp():Vec2
		return new Vec2(Math.exp(this.x), Math.exp(this.y));

	public inline function log():Vec2
		return new Vec2(Math.log(this.x), Math.log(this.y));

	public inline function exp2():Vec2
		return new Vec2(Math.pow(2, this.x), Math.pow(2, this.y));

	public inline function log2():Vec2
		return @:privateAccess new Vec2(SMath.log2f(this.x), SMath.log2f(this.y));

	public inline function sqrt():Vec2
		return new Vec2(Math.sqrt(this.x), Math.sqrt(this.y));

	public inline function inverseSqrt():Vec2
		return 1 / sqrt();

	// Common
	public inline function abs():Vec2
		return new Vec2(Math.abs(this.x), Math.abs(this.y));

	public inline function sign():Vec2
		return new Vec2(this.x > 0 ? 1 : (this.x < 0 ? -1 : 0), this.y > 0 ? 1 : (this.y < 0 ? -1 : 0));

	public inline function floor():Vec2
		return new Vec2(Math.floor(this.x), Math.floor(this.y));

	public inline function ceil():Vec2
		return new Vec2(Math.ceil(this.x), Math.ceil(this.y));

	public inline function fract():Vec2
		return (this : Vec2) - floor();

	overload public inline function mod(d:Vec2):Vec2
		return (this : Vec2) - d * ((this : Vec2) / d).floor();

	overload public inline function mod(d:Float):Vec2
		return (this : Vec2) - d * ((this : Vec2) / d).floor();

	overload public inline function min(b:Vec2):Vec2
		return new Vec2(b.x < this.x ? b.x : this.x, b.y < this.y ? b.y : this.y);

	overload public inline function min(b:Float):Vec2
		return new Vec2(b < this.x ? b : this.x, b < this.y ? b : this.y);

	overload public inline function max(b:Vec2):Vec2
		return new Vec2(this.x < b.x ? b.x : this.x, this.y < b.y ? b.y : this.y);

	overload public inline function max(b:Float):Vec2
		return new Vec2(this.x < b ? b : this.x, this.y < b ? b : this.y);

	overload public inline function clamp(minLimit:Vec2, maxLimit:Vec2)
		return max(minLimit).min(maxLimit);

	overload public inline function clamp(minLimit:Float, maxLimit:Float)
		return max(minLimit).min(maxLimit);

	overload public inline function mix(b:Vec2, t:Vec2):Vec2
		return (this : Vec2) * (1.0 - t) + b * t;

	overload public inline function mix(b:Vec2, t:Float):Vec2
		return (this : Vec2) * (1.0 - t) + b * t;

	overload public inline function step(edge:Vec2):Vec2
		return new Vec2(this.x < edge.x ? 0.0 : 1.0, this.y < edge.y ? 0.0 : 1.0);

	overload public inline function step(edge:Float):Vec2
		return new Vec2(this.x < edge ? 0.0 : 1.0, this.y < edge ? 0.0 : 1.0);

	overload public inline function smoothstep(edge0:Vec2, edge1:Vec2):Vec2 {
		var t = (((this : Vec2) - edge0) / (edge1 - edge0)).clamp(0, 1);
		return t * t * (3.0 - 2.0 * t);
	}

	overload public inline function smoothstep(edge0:Float, edge1:Float):Vec2 {
		var t = (((this : Vec2) - edge0) / (edge1 - edge0)).clamp(0, 1);
		return t * t * (3.0 - 2.0 * t);
	}

	// Geometric
	public inline function length():Float
		return Math.sqrt(this.x * this.x + this.y * this.y);

	public inline function distance(b:Vec2):Float
		return (b - this).length();

	public inline function dot(b:Vec2):Float
		return this.x * b.x + this.y * b.y;

	public inline function normalize():Vec2 {
		var v:Vec2 = this;
		var lenSq = v.dot(this);
		var denominator = lenSq == 0.0 ? 1.0 : Math.sqrt(lenSq); // for 0 length, return zero vector rather than infinity
		return v / denominator;
	}

	public inline function faceforward(I:Vec2, Nref:Vec2):Vec2
		return new Vec2(this.x, this.y) * (Nref.dot(I) < 0 ? 1 : -1);

	public inline function reflect(N:Vec2):Vec2 {
		var I = (this : Vec2);
		return I - 2 * N.dot(I) * N;
	}

	public inline function refract(N:Vec2, eta:Float):Vec2 {
		var I = (this : Vec2);
		var nDotI = N.dot(I);
		var k = 1.0 - eta * eta * (1.0 - nDotI * nDotI);
		return (eta * I - (eta * nDotI + Math.sqrt(k)) * N) * (k < 0.0 ? 0.0 : 1.0); // if k < 0, result should be 0 vector
	}

	public inline function toString()
		return 'vec2(${this.x}, ${this.y})';

	@:op([])
	private inline function arrayRead(i:Int)
		return switch i {
			case 0: this.x;
			case 1: this.y;
			default: null;
		}

	@:op([])
	private inline function arrayWrite(i:Int, v:Float)
		return switch i {
			case 0: this.x = v;
			case 1: this.y = v;
			default: null;
		}

	@:op(-a)
	static private inline function neg(a:Vec2)
		return new Vec2(-a.x, -a.y);

	@:op(++a)
	static private inline function prefixIncrement(a:Vec2) {
		++a.x;
		++a.y;
		return a.clone();
	}

	@:op(--a)
	static private inline function prefixDecrement(a:Vec2) {
		--a.x;
		--a.y;
		return a.clone();
	}

	@:op(a++)
	static private inline function postfixIncrement(a:Vec2) {
		var ret = a.clone();
		++a.x;
		++a.y;
		return ret;
	}

	@:op(a--)
	static private inline function postfixDecrement(a:Vec2) {
		var ret = a.clone();
		--a.x;
		--a.y;
		return ret;
	}

	@:op(a * b)
	static private inline function mul(a:Vec2, b:Vec2):Vec2
		return new Vec2(a.x * b.x, a.y * b.y);

	@:op(a * b) @:commutative
	static private inline function mulScalar(a:Vec2, b:Float):Vec2
		return new Vec2(a.x * b, a.y * b);

	@:op(a / b)
	static private inline function div(a:Vec2, b:Vec2):Vec2
		return new Vec2(a.x / b.x, a.y / b.y);

	@:op(a / b)
	static private inline function divScalar(a:Vec2, b:Float):Vec2
		return new Vec2(a.x / b, a.y / b);

	@:op(a / b)
	static private inline function divScalarInv(a:Float, b:Vec2):Vec2
		return new Vec2(a / b.x, a / b.y);

	@:op(a + b)
	static private inline function add(a:Vec2, b:Vec2):Vec2
		return new Vec2(a.x + b.x, a.y + b.y);

	@:op(a + b) @:commutative
	static private inline function addScalar(a:Vec2, b:Float):Vec2
		return new Vec2(a.x + b, a.y + b);

	@:op(a - b)
	static private inline function sub(a:Vec2, b:Vec2):Vec2
		return new Vec2(a.x - b.x, a.y - b.y);

	@:op(a - b)
	static private inline function subScalar(a:Vec2, b:Float):Vec2
		return new Vec2(a.x - b, a.y - b);

	@:op(b - a)
	static private inline function subScalarInv(a:Float, b:Vec2):Vec2
		return new Vec2(a - b.x, a - b.y);

	@:op(a == b)
	static private inline function equal(a:Vec2, b:Vec2):Bool
		return a.x == b.x && a.y == b.y;

	@:op(a != b)
	static private inline function notEqual(a:Vec2, b:Vec2):Bool
		return !equal(a, b);
	#end // !macro

	// macros

	/**
	 * Copy from any object with .x .y fields
	 */
	@:overload(function(source:{x:Float, y:Float}):Vec2 {})
	public macro function copyFrom(self:ExprOf<Vec2>, source:ExprOf<{x:Float, y:Float}>):ExprOf<Vec2>
		return macro {
			var self = $self;
			var source = $source;
			self.x = source.x;
			self.y = source.y;
			self;
		}

	/**
	 * Copy into any object with .x .y fields
	 */
	@:overload(function(target:{x:Float, y:Float}):{x:Float, y:Float} {})
	public macro function copyInto(self:ExprOf<Vec2>, target:ExprOf<{x:Float, y:Float}>):ExprOf<{x:Float, y:Float}>
		return macro {
			var self = $self;
			var target = $target;
			target.x = self.x;
			target.y = self.y;
			target;
		}

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyIntoArray(self:ExprOf<Vec2>, array:ExprOf<ArrayAccess<Float>>, index:ExprOf<Int>)
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			array[0 + i] = self.x;
			array[1 + i] = self.y;
			array;
		}

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyFromArray(self:ExprOf<Vec2>, array:ExprOf<ArrayAccess<Float>>, index:ExprOf<Int>)
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self.x = array[0 + i];
			self.y = array[1 + i];
			self;
		}

	// static macros

	/**
	 * Create from any object with .x .y fields
	 */
	@:overload(function(source:{x:Float, y:Float}):Vec2 {})
	public static macro function from(xy:ExprOf<{x:Float, y:Float}>):ExprOf<Vec2>
		return macro {
			var source = $xy;
			new Vec2(source.x, source.y);
		}

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public static macro function fromArray(array:ExprOf<ArrayAccess<Float>>, index:ExprOf<Int>):ExprOf<Vec2>
		return macro {
			var array = $array;
			var i:Int = $index;
			new Vec2(array[0 + i], array[1 + i]);
		}
}
