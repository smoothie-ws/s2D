package s.ui;

import kha.Framebuffer;
import s.app.Time;
import s.app.Window;
import s.app.input.MouseButton;
import s.math.SMath;
import s.graphics.Context3D;
import s.ui.FocusPolicy;
import s.ui.elements.Layer;
import s.ui.elements.Interactive;

@:allow(s.ui.Element)
@:access(s.ObjectList)
@:access(s.app.Window)
class Scene extends Layer {
	final window:Window;

	final interactive:Array<Interactive> = [];

	final hovered:Array<Interactive> = [];
	final pressed:Array<Interactive> = [];

	public var focus(default, set):Interactive = null;

	public function new(window:Window) {
		super();

		@:bypassAccessor scene = this;
		@:bypassAccessor layer = this;

		this.window = window;
		this.width = window.width;
		this.height = window.height;

		App.onUpdate(updateTree);
		window.onRender(render);
		window.onResized((w, h) -> setSize(w, h));

		var m = window.mouse;
		m.onMoved(processMouseMoved);
		m.onScrolled(processMouseScrolled);
		m.onPressed(processMousePressed);
		m.onReleased(processMouseReleased);

		var k = App.input.keyboard;
		k.onShortcut("Tab", () -> adjustFocus(1, TabFocus));

		k.onPressed(key -> if (focus?.isEnabled) focus.keyboardPressed(key));
		k.onReleased(key -> if (focus?.isEnabled) focus.keyboardReleased(key));
		k.onHold(key -> if (focus?.isEnabled) focus.keyboardHold(key));
		k.onTyped(char -> if (focus?.isEnabled) focus.keyboardTyped(char));
		k.onHotkey(hotkey -> if (focus?.isEnabled) focus.keyboardHotkey(hotkey));
	}

	override function updateTree() {
		if (!dirty)
			return;

		super.updateTree();

		processMouseMoved(window.mouse.x, window.mouse.y, 0, 0);

		if (!children.dirty)
			return;

		for (el in pressed.copy())
			if (!interactive.contains(el))
				while (el.pressedButtons.length > 0)
					el.release(el.pressedButtons[el.pressedButtons.length - 1], window.mouse.x, window.mouse.y);
	}

	override function updateOrder()
		if (children.dirty) {
			drawable.resize(0);
			interactive.resize(0);
		}

	@:access(s.assets.Image)
	function render(framebuffer:Framebuffer) {
		final g2 = framebuffer.g2;

		g2.begin(color);
		g2.drawImage(texture, 0, 0);

		#if debug
		g2.font = s.assets.Font.get("default");
		g2.fontSize = 14;

		final time = Time.delta;
		final fps = Std.int(1.0 / time);
		var offset = 5;

		inline function drawInfo(text:String) {
			g2.color = Black;
			g2.drawString(text, 6, offset + 1);
			g2.color = White;
			g2.drawString(text, 5, offset);
			offset += 16;
		}

		drawInfo("FPS: " + fps);
		drawInfo("LAT: " + roundTo(time * 1000, 1));
		// draw("CPU: " + roundTo(Context3D.cpuTime, 1));
		// draw("GPU: " + roundTo(Context3D.gpuTime, 1));
		drawInfo("DCS: " + Context3D.drawCalls);
		drawInfo("IBA: " + Context3D.ibAllocations);
		drawInfo("VBA: " + Context3D.vbAllocations);

		Context3D.resetDebugInfo();
		#end

		g2.end();
	}

	function adjustFocus(d:Int, policy:FocusPolicy) {
		if (interactive.length == 0) {
			focus = null;
			return;
		}

		var start = interactive.indexOf(focus);
		if (start < 0)
			start = d >= 0 ? 0 : interactive.length - 1;
		else
			start = (start + d + interactive.length) % interactive.length;

		for (step in 0...interactive.length) {
			final i = (start + step * (d >= 0 ? 1 : -1) + interactive.length) % interactive.length;
			final el = interactive[i];
			if (el.isEnabled && el.focusPolicy.matches(policy)) {
				focus = el;
				return;
			}
		}
	}

	function processMouseMoved(x:Int, y:Int, dx:Int, dy:Int):Void {
		final nextHovered:Array<Interactive> = [];
		var accepted = false;

		for (el in interactive) {
			if (accepted || !el.isEnabled || !el.covers(x, y))
				continue;

			nextHovered.push(el);
			if (!el.propagateMouseEvents)
				accepted = true;
		}

		for (el in hovered.copy())
			if (!nextHovered.contains(el)) {
				final p = el.mapFromGlobal(x, y);
				el.exit(p.x, p.y);
			}

		for (el in nextHovered)
			if (!hovered.contains(el)) {
				final p = el.mapFromGlobal(x, y);
				el.enter(p.x, p.y);
			} else {
				final p = el.realTransform * vec2(dx, dy);
				el.mouse(p.x, p.y);
			}

		hovered.resize(0);
		for (el in nextHovered)
			hovered.push(el);
	}

	function processMousePressed(b:MouseButton, x:Int, y:Int):Void {
		var newFocus = null;
		for (el in hovered)
			if (el.isEnabled) {
				if (el.focusPolicy.matches(PointerFocus))
					newFocus = el;
				final p = el.mapFromGlobal(x, y);
				el.press(b, p.x, p.y);
				if (!el.propagateMouseEvents && el.acceptedButtons.matches(b))
					break;
			}
		focus = newFocus;
	}

	function processMouseReleased(b:MouseButton, x:Int, y:Int):Void
		for (el in pressed.copy()) {
			final p = el.mapFromGlobal(x, y);
			el.release(b, p.x, p.y);
		}

	function processMouseScrolled(d:Int):Void {
		adjustFocus(d, WheelFocus);
		for (el in hovered)
			if (el.isEnabled) {
				el.scroll(d);
				if (!el.propagateMouseEvents)
					break;
			}
	}

	function set_focus(value:Interactive):Interactive {
		if (focus == value)
			return focus;
		if (focus != null) {
			@:bypassAccessor focus.isFocused = false;
			focus.isFocusedDirty = true;
		}
		if (value != null) {
			@:bypassAccessor value.isFocused = true;
			value.isFocusedDirty = true;
		}
		return focus = value;
	}
}
