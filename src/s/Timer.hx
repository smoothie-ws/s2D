package s;

import s.app.Time;

@:access(s.app.Time)
/**
 * Utility timer built on top of [`Time`](s.app.Time) scaled time listeners.
 *
 * `Timer` is a small convenience wrapper for one-shot, repeated, and looping
 * delayed callbacks driven by scaled engine time. It is a good fit for gameplay
 * sequencing and animation triggers that should respect time scaling.
 *
 * Typical usage:
 * ```haxe
 * Timer.set(() -> trace("boom"), 0.5);
 * ```
 */
class Timer {
	var slot:{callback:Void->Void, time:Float};

	final callback:Void->Void;
	final delay:Float;

	/**
	 * Whether the timer is currently scheduled.
	 *
	 * Setting this to `true` starts the timer, and setting it to `false` stops it.
	 */
	public var started(get, set):Bool;

	/**
	 * Creates and immediately starts a timer.
	 *
	 * This is the shortest way to schedule a one-shot callback.
	 *
	 * @param callback Function to call when the timer fires.
	 * @param delay Delay in seconds.
	 * @return The created timer.
	 */
	public static function set(callback:Void->Void, delay:Float):Timer {
		final timer = new Timer(callback, delay);
		timer.start();
		return timer;
	}

	/**
	 * Creates a timer without starting it.
	 *
	 * Use [`start`](s.Timer.start), [`repeat`](s.Timer.repeat), or [`loop`](s.Timer.loop)
	 * to activate it later.
	 *
	 * @param callback Function to call when the timer fires.
	 * @param delay Delay in seconds.
	 */
	public function new(callback:Void->Void, delay:Float = 1.0) {
		this.callback = callback;
		this.delay = delay;
	}

	/**
	 * Starts the timer.
	 *
	 * Starting resets the active callback chain back to the original one-shot callback.
	 *
	 * @param lock Whether to skip starting when the timer is already running.
	 * @return `true` if the timer was started.
	 */
	public function start(lock:Bool = true):Bool {
		if (lock && started)
			return false;
		if (started)
			stop();
		slot = Time.notifyOnTime(callback, Time.time + delay);
		return true;
	}

	/**
	 * Stops the timer if it is scheduled.
	 *
	 * This also restores the original callback when the timer had been configured
	 * through [`repeat`](s.Timer.repeat) or [`loop`](s.Timer.loop).
	 */
	public function stop():Bool {
		final removed = slot != null && Time.timeListeners.remove(slot);
		slot = null;
		return removed;
	}

	/**
	 * Starts the timer repeatedly.
	 *
	 * Repetitions are driven by scaled time, just like [`start`](s.Timer.start).
	 *
	 * @param count Number of repetitions. Use `0` for an infinite repeat.
	 * @param lock Whether to skip starting when the timer is already running.
	 * @return `true` if repeating was started.
	 */
	public function repeat(count:Int = 1, lock:Bool = true):Bool {
		if (count < 0)
			return false;
		if (lock && started)
			return false;
		if (started)
			stop();

		final loop = count == 0;
		var remaining = count;
		var repeatCallback:Void->Void = null;
		repeatCallback = () -> {
			callback();
			if (!loop && --remaining <= 0) {
				slot = null;
				return;
			}
			slot = Time.notifyOnTime(repeatCallback, Time.time + delay);
		};
		slot = Time.notifyOnTime(repeatCallback, Time.time + delay);
		return true;
	}

	/**
	 * Starts the timer as an infinite loop.
	 *
	 * This is a convenience alias for `repeat(0, lock)`.
	 *
	 * @param lock Whether to skip starting when the timer is already running.
	 * @return `true` if looping was started.
	 */
	public function loop(lock:Bool = true):Bool
		return repeat(0, lock);

	function get_started():Bool
		return Time.timeListeners.contains(slot);

	function set_started(value:Bool):Bool {
		if (!started && value)
			start();
		else if (started && !value)
			stop();
		return started;
	}
}
