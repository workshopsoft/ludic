---
id: tween-to
name: Tween.to
category: tween
kind: namespace-method
tokens: Tween.to
sig: Tween.to(from, to, dur, ease) -> handle
tip: Start a fluent, engine-advanced tween and return a handle.
order: 30
ns: Tween
member: to
---

Starts a <strong>stateful tween handle</strong> — from <code>from</code> to <code>to</code> over <code>dur</code> ticks with easing <code>ease</code> — and returns an integer handle. Unlike the pure <a href="tween-progress"><code>Tween.progress</code></a> interpolators (which the game drives from its own timer), a handle is <em>advanced by the engine</em> one tick per frame: fire it once, then read <a href="tween-value"><code>Tween.value</code></a> each frame and <a href="tween-done"><code>Tween.done</code></a> to know when it finishes. <a href="tween-chain"><code>Tween.chain</code></a> and <a href="tween-delay"><code>Tween.delay</code></a> append segments for a sequence. Integer and deterministic, so a sequence plays identically under replay. The handle pool is fixed-size and reuses finished slots.

Parameters:
- `from`, `to` — the start and end values (integer game units)
- `dur` — the segment length in engine ticks
- `ease` — 0 linear, 1 in, 2 out, 3 in-out

```ludic
program Demo {
  property SpriteAnim { ticks: int = 0, fps: int = 0, frames: int = 0, mode: int = 0, frame: int = 0 }
  property Pop { h: int = 0 }
  model Coin { SpriteAnim, Pop }
  entry {
    spawn Coin { Pop { h: 0 } }
    let e = World.query_next(World.prop_id("Pop"), 0)
    let f = World.field_id(World.prop_id("Pop"), "h")
    World.set(e, World.prop_id("Pop"), f, Tween.to(0, 40, 20, 2))   # pop upward
    quit()
  }
}
```
