---
id: anim-on_frame
name: Anim.on_frame
category: anim
kind: namespace-method
tokens: Anim.on_frame
sig: Anim.on_frame(entity, frame)
tip: Arm a frame event — the engine flags the tick a clip lands on this frame.
order: 32
ns: Anim
member: on_frame
---

Arms a <strong>frame event</strong> on an entity's <code>SpriteAnim</code>: the engine sets the component's <code>event_fired</code> flag on the tick the clip <em>first lands</em> on <code>frame</code> — a footstep on the contact cell, a hitbox going live mid-swing. Gameplay reads the flag with <a href="anim-fired"><code>Anim.fired</code></a> in its own handler and reacts (emit its own event, spawn, play a sound). The engine detects the boundary; the game owns the reaction, so it stays inside the deterministic, no-runtime-dispatch event model. Requires the component to carry <code>event_frame</code> and <code>event_fired</code> fields.

Parameters:
- `entity` — the entity carrying `SpriteAnim`
- `frame` — the cell index that should fire the event

```ludic
program Demo {
  property SpriteAnim { ticks: int = 0, fps: int = 0, frames: int = 0, mode: int = 0, frame: int = 0, event_frame: int = 0, event_fired: int = 0 }
  model Hero { SpriteAnim }
  entry {
    spawn Hero { SpriteAnim { fps: 12, frames: 6, mode: 0 } }
    let e = World.query_next(World.prop_id("SpriteAnim"), 0)
    Anim.on_frame(e, 3)                 # fire when the run clip hits its contact frame
    tick_fixed()
    if Anim.fired(e) { print(1) }
    quit()
  }
}
```
