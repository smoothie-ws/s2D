package s.ui;

extern enum abstract Alignment(Int) from Int to Int {
	var None:Int = 0;

	var AlignLeft:Int = 1 << 0;
	var AlignRight:Int = 1 << 1;
	var AlignHCenter:Int = 1 << 2;
	var AlignTop:Int = 1 << 3;
	var AlignBottom:Int = 1 << 4;
	var AlignVCenter:Int = 1 << 5;

	var AlignLeftTop = AlignLeft | AlignTop;
	var AlignLeftCenter = AlignLeft | AlignVCenter;
	var AlignLeftBottom = AlignLeft | AlignBottom;

	var AlignRightTop = AlignRight | AlignTop;
	var AlignRightCenter = AlignRight | AlignVCenter;
	var AlignRightBottom = AlignRight | AlignBottom;

	var AlignTopLeft = AlignLeftTop;
	var AlignTopCenter = AlignTop | AlignHCenter;
	var AlignTopRight = AlignRightTop;

	var AlignBottomLeft = AlignLeftBottom;
	var AlignBottomCenter = AlignBottom | AlignHCenter;
	var AlignBottomRight = AlignRightBottom;

	var AlignCenter = AlignHCenter | AlignVCenter;
	
	var AlignCenterLeft = AlignLeftCenter;
	var AlignCenterRight = AlignRightCenter;

	var AlignCenterTop = AlignTopCenter;
	var AlignCenterBottom = AlignBottomCenter;

	public inline function matches(value:Alignment)
		return this & value != 0;

	public inline function toString():String {
		var strs = [];

		if (this & AlignLeft != 0)
			strs.push("AlignLeft");
		else if (this & AlignHCenter != 0)
			strs.push("AlignHCenter");
		else if (this & AlignRight != 0)
			strs.push("AlignRight");

		if (this & AlignTop != 0)
			strs.push("AlignTop");
		else if (this & AlignVCenter != 0)
			strs.push("AlignVCenter");
		else if (this & AlignBottom != 0)
			strs.push("AlignBottom");

		return strs.join(" + ");
	}
}
