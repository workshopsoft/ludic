---
id: anim-finished
name: Anim.finished
category: anim
kind: namespace-method
tokens: Anim.finished
sig: Anim.finished(timer, fps, count) -> bool
tip: True once a one-shot clip has run past its last frame.
order: 4
ns: Anim
member: finished
---

Returns <code>true</code> once <code>floor(timer * fps) >= count</code> — i.e. a one-shot clip driven by <a href="anim-once"><code>Anim.once</code></a> has played its final frame. Use it to despawn an effect, fire a follow-up, or switch back to an idle clip.

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `fps` — frames per second
- `count` — number of frames in the clip

```ludic
program Demo {
  property Blast { timer: fixed = 0.0 }
  model Boom { Blast }
  handler Run phase Update {
    Blast.timer = Blast.timer + Time.delta()
    if Anim.finished(Blast.timer, 15, 6) { despawn (self()) }
  }
}
```
