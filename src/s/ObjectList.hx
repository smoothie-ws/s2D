package s;

@:forward()
@:forward.new
@:allow(s.Object)
extern abstract ObjectList<T:Object<T>>(ObjectListData<T>) to ObjectListData<T> {
	private var dirty(get, set):Bool;
	private var object(get, never):T;
	private var list(get, never):Array<T>;

	public var count(get, never):Int;

	public inline function excluded(x:T)
		return copy().remove(x);

	public inline function concat(a:Array<T>):Array<T>
		return list.concat(a);

	public inline function join(sep:String):String
		return list.join(sep);

	public inline function pop():Null<T>
		return setObjectParent(list.pop(), null);

	public inline function add(x:T):T {
		if (x == null || x == object || contains(x))
			return x;
		list.push(x);
		return setObjectParent(x, object);
	}

	public inline function reverse():Void
		list.reverse();

	public inline function shift():Null<T>
		return setObjectParent(list.shift(), null);

	public inline function slice(pos:Int, ?end:Int):Array<T>
		return list.slice(pos, end);

	public inline function sort(f:T->T->Int):Void
		list.sort(f);

	public inline function splice(pos:Int, len:Int):Array<T> {
		var els = list.splice(pos, len);
		for (x in els)
			setObjectParent(x, null);
		return els;
	}

	public inline function toString():String
		return list.toString();

	public inline function unshift(x:T):T {
		if (x == null || x == object || contains(x))
			return x;
		list.unshift(x);
		return setObjectParent(x, object);
	}

	public inline function insert(pos:Int, x:T):T {
		if (x == null || x == object || contains(x))
			return x;
		list.insert(pos, x);
		return setObjectParent(x, object);
	}

	public inline function remove(x:T):Bool {
		if (x != null && list.remove(x)) {
			setObjectParent(x, null);
			return true;
		}
		return false;
	}

	public inline function replace(x:T, y:T):Bool {
		var ind = indexOf(x);
		if (ind >= 0) {
			setObjectParent(list[ind], null);
			list[ind] = x;
			setObjectParent(x, object);
			return true;
		}
		return false;
	}

	public inline function swap(x:Int, y:Int):Bool {
		if (x < 0 || x >= count || y < 0 || y >= count)
			return false;
		var c = list[x];
		list[x] = list[y];
		list[y] = c;
		return dirty = true;
	}

	public inline function contains(x:T):Bool
		return list.contains(x);

	public inline function indexOf(x:T, ?fromIndex:Int):Int
		return list.indexOf(x, fromIndex);

	public inline function lastIndexOf(x:T, ?fromIndex:Int):Int
		return list.lastIndexOf(x, fromIndex);

	@:to
	public inline function copy():Array<T>
		return list.copy();

	public inline function iterator():haxe.iterators.ArrayIterator<T>
		return list.iterator();

	public inline function keyValueIterator():haxe.iterators.ArrayKeyValueIterator<T>
		return list.keyValueIterator();

	public inline function map<S>(f:T->S):Array<S>
		return list.map(f);

	public inline function filter(f:T->Bool):Array<T>
		return list.filter(f);

	public inline function destroy()
		while (count > 0)
			list[0].destroy();

	@:op([])
	private inline function arrayRead(i:Int):T
		return list[i];

	@:op([])
	private inline function arrayWrite(i:Int, x:T):T {
		if (!contains(x)) {
			setObjectParent(list[i], null);
			list[i] = x;
			setObjectParent(x, object);
		}
		return x;
	}

	private inline function setObjectParent(x:T, p:T) @:privateAccess {
		if (x != null && x != object) {
			dirty = true;
			x.parentDirty = true;
			@:bypassAccessor x.parent = p;
		}
		return x;
	}

	private inline function get_dirty():Bool
		return @:privateAccess this.dirty;

	private inline function set_dirty(value:Bool):Bool
		return @:privateAccess this.dirty = value;

	private inline function get_object():T
		return @:privateAccess this.object;

	private inline function get_list():Array<T>
		return @:privateAccess this.list;

	private inline function get_count():Int
		return list.length;
}

private class ObjectListData<T:Object<T>> extends s.shortcut.AttachedAttribute<T> {
	var list:Array<T> = [];
}
