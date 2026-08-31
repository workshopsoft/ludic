---
id: anim-fired
name: Anim.fired
category: anim
kind: namespace-method
tokens: Anim.fired
sig: Anim.fired(entity) -> bool
tip: Did the entity's clip land on its armed frame event this tick?
order: 33
ns: Anim
member: fired
---

Returns whether an entity's <code>SpriteAnim</code> clip landed on the frame armed by <a href="anim-on_frame"><code>Anim.on_frame</code></a> this tick — the read side of a frame event. It is true only on the single tick the clip first reaches that cell, so a game can poll it each frame and turn it into a gameplay action (emit an event, spawn a hitbox, play a footstep). Returns <code>false</code> if the entity has no <code>SpriteAnim</code> or no <code>event_fired</code> field.

Parameters:
- `entity` — the entity carrying `SpriteAnim`

```ludic
program Demo {
  property SpriteAnim { ticks: int = 0, fps: int = 0, frames: int = 0, mode: int = 0, frame: int = 0, event_frame: int = 0, event_fired: int = 0 }
  model Hero { SpriteAnim }
  handler Step phase Update {
    let e = World.query_next(World.prop_id("SpriteAnim"), 0)
    if Anim.fired(e) { print(42) }      # react: footstep, hitbox, event…
  }
}
```
