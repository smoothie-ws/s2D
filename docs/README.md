# Building API docs:

-   Install [Haxe](https://haxe.org/) and [dox](https://github.com/HaxeFoundation/dox)
-   Install [Node.js](https://nodejs.org/) (required by Kha `make.js`)
-   Open terminal at `sengine/api` _(`cd sengine/api`)_
-   Run `haxe build.hxml` to generate html into the `build/html/pages` directory

Notes:
-   `build.hxml` runs `prepare-kha-hxml.js`, which generates `../build/project-html5.hxml` locally.
-   If Kha cannot be auto-detected, set `KHA_PATH` to your Kha directory and rerun the command.

# Dox Style

This project uses `dox` comments as public API documentation, not as inline implementation notes.
The goal is to help a user understand what an API is for, when to use it, and what behavior to expect.

## General rules

-   Write docs for public types and public API members.
-   Put the doc block before any metadata such as `@:from`, `@:to`, `@:signal`, or `@:alias`.
-   Use GitHub-flavored Markdown when it improves readability, but keep the prose compact.
-   Prefer plain language over repeating the identifier name.
-   Document behavior and intent first; implementation details only when they explain visible behavior.

## What to write

For a **type**:

-   Start with a short summary sentence.
-   Explain what role the type plays in the engine.
-   Describe typical usage and when to choose it over neighboring APIs.
-   Mention important constraints, lifetime rules, or hidden costs.
-   Include a short example when the API is not obvious.

For a **field or property**:

-   Explain what the value represents.
-   Explain who is expected to set it and what changing it affects.
-   Mention ranges, units, defaults, and interaction with related fields.
-   If a field is only informative, state that clearly.

For a **method**:

-   Explain what it does from the caller's point of view.
-   Note whether it mutates state, schedules future work, waits for assets, or can no-op.
-   Describe parameter meaning in practical terms, not only by type.
-   Mention return semantics and edge cases.

## Recommended structure

Use this shape when a member needs more than a one-line description:

```haxe
/**
 * Short summary.
 *
 * What this API represents and why it exists.
 *
 * Typical usage:
 * ```haxe
 * // example
 * ```
 *
 * Caveats:
 * - important constraint
 * - interaction with related fields
 *
 * @param value What the parameter means in practice.
 * @return What the caller gets back.
 * @default Default behavior or value when relevant.
 * @see https://...
 */
```

## Examples and `@see`

-   Add examples when the usage is not obvious from the signature alone.
-   Keep examples short and realistic.
-   Use `@see` for external references only when they add real context:
    color spaces, easing curves, alpha compositing, timing semantics, and similar topics.
-   Do not add external links to trivial members whose meaning is already obvious.

## Tone

-   Prefer precise, practical wording.
-   Avoid filler like "This function simply..."
-   Avoid undocumented assumptions about ordering, units, or ownership.
-   If something is intentionally informational, derived, or read-only in practice, say so explicitly.
