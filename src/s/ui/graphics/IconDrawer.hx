package s.ui.graphics;

import s.ui.elements.Icon;

class IconDrawer<T:Icon = Icon> extends TexturedDrawer<T> {
	function new()
		super("texture", "image");
}
