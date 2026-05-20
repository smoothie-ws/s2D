package s;

typedef Transition = Void->Void;

abstract State({t:Map<State, Transition>}) from {t:Map<State, Transition>} to {t:Map<State, Transition>} {
	@:from
	static inline function fromArray(value:Array<State>):State
		return new State();

	@:from
	static inline function fromMap(value:Map<State, Transition>):State
		return {t: value};

	public inline function new()
		this = {t: new Map<State, Transition>()};

	@:op([])
	public inline function get(state:State)
		return this.t.get(state);

	@:op([])
	public inline function set(state:State, transition:Transition)
		return this.t.set(state, transition);

	public inline function has(state:State):Bool
		return this.t.exists(state);

	public inline function clear()
		return this.t.clear();

	public inline function remove(state:State):Bool
		return this.t.remove(state);
}

/**
 * Minimal finite state machine with explicit transitions between states.
 *
 * `FSM` keeps track of one current state and only allows transitions that are
 * explicitly registered on that state. This keeps state flow easy to reason
 * about: if there is no transition, [`goto`](s.FSM.goto) simply does nothing.
 *
 * Typical usage:
 * ```haxe
 * var idle = new State();
 * var walking = new State();
 *
 * idle[walking] = () -> trace("start walking");
 * walking[idle] = () -> trace("stop walking");
 *
 * var fsm = new FSM(idle);
 * fsm.goto(walking);
 * ```
 */
class FSM {
	/**
	 * Current active state.
	 *
	 * This field can be assigned directly, but in normal usage transitions should
	 * go through [`goto`](s.FSM.goto) so transition callbacks are respected.
	 */
	public var current(default, set):State;

	/**
	 * Creates a finite state machine.
	 *
	 * @param state Initial state. May be `null`, in which case [`goto`](s.FSM.goto)
	 * cannot do anything until a state is assigned.
	 */
	public function new(state:State)
		@:bypassAccessor current = state;

	/**
	 * Transitions to another state if the current state defines a transition for it.
	 *
	 * If the transition exists, the target state becomes current and the
	 * transition callback is invoked immediately.
	 *
	 * @param to Target state.
	 */
	public function goto(to:State):Bool {
		if (to == null || current == null || !current.has(to))
			return false;
		var transition = current[to];
		if (transition != null)
			transition();
		@:bypassAccessor current = to;
		return true;
	}

	function set_current(value:State) {
		goto(value);
		return current;
	}
}
