---
id: motion-to
name: Motion.to
category: motion
kind: namespace-method
tokens: Motion.to
sig: Motion.to(entity, from, to, dur, ease)
tip: Start a value tween on an entity's Motion component in one call.
order: 1
ns: Motion
member: to
---

Starts a value tween on an entity's <code>Motion</code> component: it sets <code>from</code>, <code>to</code>, <code>dur</code> and <code>ease</code>, resets the timer, and seeds <code>value</code> at <code>from</code>, so the engine interpolates <code>value</code> from <code>from</code> to <code>to</code> over <code>dur</code> ticks and latches <code>done</code> at the end. One call replaces setting five fields by hand — a health bar sliding, a door opening, an alpha fade. A no-op if the entity has no <code>Motion</code>. Integer and deterministic.

Parameters:
- `entity` — the entity carrying `Motion`
- `from`, `to` — the start and end values (integer game units)
- `dur` — the duration in engine ticks
- `ease` — 0 linear, 1 in, 2 out, 3 in-out

```ludic
program Demo {
  property Motion { ticks: int = 0, dur: int = 0, from: int = 0, to: int = 0, ease: int = 0, value: int = 0, done: int = 0 }
  model Door { Motion }
  entry {
    spawn Door { Motion { } }
    let e = World.query_next(World.prop_id("Motion"), 0)
    Motion.to(e, 0, 64, 30, 2)          # slide 0 -> 64 over 30 ticks, ease-out
    quit()
  }
}
```
