package s.ui.elements;

import s.ui.FocusPolicy;
import s.app.Time;
import s.app.input.KeyCode;
import s.app.input.Shortcut;
import s.app.input.MouseButton;
import s.app.input.MouseCursor;

@:allow(s.ui.Scene)
class Interactive extends Element {
	final clicks:Map<MouseButton, Float> = [];
	final pending:Array<MouseButton> = [];
	final holdTimers:Map<MouseButton, Timer> = [];

	public var propagateMouseEvents:Bool = false;
	public var acceptedButtons:MouseButton = MouseButton.Left;

	public var cursor:MouseCursor;
	public var focusPolicy:FocusPolicy = InputFocus;
	public var holdInterval:Float = 0.3;
	public var doubleClickInterval:Float = 0.5;

	public final pressedButtons:Array<MouseButton> = [];

	@:attr(interaction) public var isEnabled:Bool = true;
	@:attr(interaction) public var isFocused(default, set):Bool = false;

	@:attr public var isHovered:Bool = false;
	@:attr public var mouseX:Float = 0.0;
	@:attr public var mouseY:Float = 0.0;

	@:attr public var isPressed:Bool = false;
	@:attr public var pressX:Float = 0.0;
	@:attr public var pressY:Float = 0.0;

	@:attr public var clickX:Float = 0.0;
	@:attr public var clickY:Float = 0.0;

	@:signal public function mouseEntered();

	@:signal public function mouseExited();

	@:signal public function mouseMoved(dx:Float, dy:Float);

	@:signal public function mouseScrolled(delta:Int);

	@:signal public function mousePressed(button:MouseButton);

	@:signal public function mouseReleased(button:MouseButton);

	@:signal public function mouseHold(button:MouseButton);

	@:signal public function mouseClicked(button:MouseButton);

	@:signal public function mouseDoubleClicked(button:MouseButton);

	@:signal(button) public function mouseButtonPressed(button:MouseButton);

	@:signal(button) public function mouseButtonReleased(button:MouseButton);

	@:signal(button) public function mouseButtonHold(button:MouseButton);

	@:signal(button) public function mouseButtonClicked(button:MouseButton);

	@:signal(button) public function mouseButtonDoubleClicked(button:MouseButton);

	@:signal public function keyboardPressed(key:KeyCode);

	@:signal public function keyboardReleased(key:KeyCode);

	@:signal public function keyboardHold(key:KeyCode);

	@:signal public function keyboardTyped(char:String);

	@:signal public function keyboardHotkey(hotkey:Hotkey);

	@:signal(key) public function keyboardKeyPressed(key:KeyCode);

	@:signal(key) public function keyboardKeyReleased(key:KeyCode);

	@:signal(key) public function keyboardKeyHold(key:KeyCode);

	@:signal(char) public function keyboardCharTyped(char:String);

	public function new() {
		super();

		onMouseHold(b -> mouseButtonHold(b));
		onKeyboardPressed(k -> keyboardKeyPressed(k));
		onKeyboardReleased(k -> keyboardKeyReleased(k));
		onKeyboardHold(k -> keyboardKeyHold(k));
		onKeyboardTyped(c -> keyboardCharTyped(c));
	}

	public function setCursor(cursor:MouseCursor)
		this.cursor = cursor;

	public function setFocusPolicy(focusPolicy:FocusPolicy)
		this.focusPolicy = focusPolicy;

	public function enter(x:Float, y:Float) {
		mouseX = x;
		mouseY = y;
		isHovered = true;

		if (cursor != null && scene != null)
			scene.window.mouse.cursor = cursor;

		mouseEntered();
	}

	public function exit(x:Float, y:Float) {
		mouseX = x;
		mouseY = y;
		isHovered = false;

		for (b in holdTimers.keys())
			holdTimers[b].stop();
		holdTimers.clear();

		pending.resize(0);

		if (cursor != null && scene != null)
			scene.window.mouse.cursor = Default;

		mouseExited();
	}

	public function mouse(dx:Float, dy:Float) {
		mouseX += dx;
		mouseY += dy;

		mouseMoved(dx, dy);
	}

	public function press(button:MouseButton, x:Float, y:Float) {
		if (!acceptedButtons.matches(button))
			return;

		pressX = x;
		pressY = y;
		isPressed = true;

		if (scene != null && !scene.pressed.contains(this))
			scene.pressed.push(this);

		pending.push(button);
		pressedButtons.push(button);

		holdTimers[button] = Timer.set(() -> {
			holdTimers.remove(button);
			pending.remove(button);
			mouseHold(button);
		}, holdInterval);

		mouseButtonPressed(button);
		mousePressed(button);
	}

	public function release(button:MouseButton, x:Float, y:Float) {
		if (!pressedButtons.remove(button))
			return;

		final timer = holdTimers[button];
		if (timer != null) {
			timer.stop();
			holdTimers.remove(button);
		}

		if (pending.remove(button))
			click(button, x, y);

		isPressed = pressedButtons.length > 0;
		if (scene != null && !isPressed)
			scene.pressed.remove(this);

		mouseButtonReleased(button);
		mouseReleased(button);
	}

	public function scroll(delta:Int)
		mouseScrolled(delta);

	public function click(button:MouseButton, x:Float, y:Float) {
		if (!acceptedButtons.matches(button))
			return;

		clickX = x;
		clickY = y;

		mouseButtonClicked(button);
		mouseClicked(button);

		var time = Time.time;
		var previous = clicks.get(button);
		clicks.set(button, time);

		if (previous != null && time - previous <= doubleClickInterval)
			doubleClick(button, x, y);
	}

	public function doubleClick(button:MouseButton, x:Float, y:Float) {
		clickX = x;
		clickY = y;
		mouseButtonDoubleClicked(button);
		mouseDoubleClicked(button);
	}

	override function update() {
		super.update();

		if (scene != null && realVisible && layer.children.dirty)
			scene.interactive.unshift(this);
	}

	function set_isFocused(value:Bool) {
		if (value && scene != null) {
			scene.focus = this;
			return isFocused;
		}
		return isFocused = false;
	}
}
