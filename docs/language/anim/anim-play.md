---
id: anim-play
name: Anim.play
category: anim
kind: namespace-method
tokens: Anim.play
sig: Anim.play(entity, clip) | Anim.play(entity, fps, frames, mode)
tip: Start (or restart) a spritesheet clip on an entity in one call.
order: 30
ns: Anim
member: play
---

Starts a spritesheet clip on an entity's <code>SpriteAnim</code> component and rewinds it to its first cell, so gameplay swaps or replays an animation with one call instead of setting five fields by hand. Two forms: <code>Anim.play(entity, "run")</code> plays a <a href="anim-clip"><code>named clip</code></a> registered with <code>Anim.clip</code>; <code>Anim.play(entity, fps, frames, mode)</code> sets the clip directly (<code>mode</code> 0 loop, 1 once, 2 ping-pong). A no-op if the entity has no <code>SpriteAnim</code>. The engine advances the clip from there each tick.

Parameters:
- `entity` — the entity carrying `SpriteAnim`
- `clip` — a registered clip name (2-argument form), **or**
- `fps`, `frames`, `mode` — the clip rate, cell count and play mode (4-argument form)

```ludic
program Demo {
  property SpriteAnim { ticks: int = 0, fps: int = 0, frames: int = 0, mode: int = 0, frame: int = 0 }
  model Hero { SpriteAnim }
  entry {
    Anim.clip("run", 6, 12, 0)
    spawn Hero { SpriteAnim { } }
    let e = World.query_next(World.prop_id("SpriteAnim"), 0)
    Anim.play(e, "run")                 # by name
    Anim.play(e, 8, 4, 1)               # or directly: 4 frames @ 8fps, once
    quit()
  }
}
```
