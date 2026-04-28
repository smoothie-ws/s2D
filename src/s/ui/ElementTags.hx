package s.ui;

import s.ui.Element;

using s.extensions.StringExt;

@:forward
@:forward.new
extern abstract ElementTags(ElementTagsData) {
	public var count(get, never):Int;

	@:from
	public static inline function fromString(value:String):ElementTags
		return fromArray(value == null ? null : ~/[\s,;#]+/g.replace(value.trim(), ",").split(",").filter(t -> t != ""));

	@:from
	public static inline function fromArray(value:Array<String>):ElementTags
		return new ElementTags(value?.map(t -> t.trim()).filter(t -> t != "") ?? [], null);

	public inline function new(tags:Array<String>, ?object:Element) {
		this = new ElementTagsData(object);
		for (tag in tags)
			add(tag);
	}

	public inline function has(tag:String):Bool
		return this.tags.contains(tag);

	public inline function map<T>(f:String->T)
		return this.tags.map(f);

	public inline function iterator()
		return this.tags.iterator();

	@:to
	public inline function toArray():Array<String>
		return this.tags;

	@:to
	public inline function toString():String
		return map(t -> " #" + t).join("");

	@:op(a += b)
	public inline function add(tag:String):Void {
		if (!has(tag))
			this.tags.push(tag);
		@:privateAccess this.dirty = true;
	}

	@:op(a -= b)
	public inline function remove(tag:String):Void
		if (this.tags.remove(tag))
			@:privateAccess this.dirty = true;

	@:op(a == b)
	public inline function equals(value:ElementTags) {
		if (this.tags.length != value.tags.length)
			return false;
		var eq = true;
		for (t in this.tags)
			if (!value.has(t)) {
				eq = false;
				break;
			}
		return eq;
	}

	@:op(a != b)
	public inline function notEquals(value:ElementTags)
		return !equals(value);

	private inline function get_count():Int
		return this.tags.length;
}

@:allow(s.ui.Element)
@:allow(s.ui.ElementTags)
private class ElementTagsData extends s.shortcut.AttachedAttribute<Element> {
	final tags:Array<String> = [];
}
