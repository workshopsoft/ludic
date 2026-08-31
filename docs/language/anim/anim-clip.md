---
id: anim-clip
name: Anim.clip
category: anim
kind: namespace-method
tokens: Anim.clip
sig: Anim.clip(name, frames, fps, mode)
tip: Register a named spritesheet clip so Anim.play can play it by name.
order: 31
ns: Anim
member: clip
---

Registers (or updates) a spritesheet clip under a <code>name</code>, so gameplay refers to a motion by name — <code>Anim.play(entity, "run")</code> — instead of repeating its frame count and rate everywhere. The clip stores <code>frames</code> (cell count), <code>fps</code> (rate) and <code>mode</code> (0 loop, 1 once, 2 ping-pong). Names compare by identity (a string literal interns to one pointer), and the registry holds up to 32 clips. Registering the same name again overwrites it.

Parameters:
- `name` — the clip name (a string)
- `frames` — number of cells in the clip
- `fps` — playback rate in frames per second
- `mode` — 0 loop, 1 once (clamp on last), 2 ping-pong

```ludic
program Demo {
  property SpriteAnim { ticks: int = 0, fps: int = 0, frames: int = 0, mode: int = 0, frame: int = 0 }
  model Hero { SpriteAnim }
  entry {
    Anim.clip("idle", 2, 4, 0)          # a slow 2-frame idle loop
    Anim.clip("run",  6, 12, 0)         # a 6-frame run
    Anim.clip("hit",  3, 15, 1)         # a one-shot hit reaction
    spawn Hero { SpriteAnim { } }
    Anim.play(World.query_next(World.prop_id("SpriteAnim"), 0), "run")
    quit()
  }
}
```
