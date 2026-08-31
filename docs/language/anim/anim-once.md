---
id: anim-once
name: Anim.once
category: anim
kind: namespace-method
tokens: Anim.once
sig: Anim.once(timer, fps, count) -> int
tip: A non-looping frame index that clamps on the last frame.
order: 2
ns: Anim
member: once
---

Like <a href="anim-frame"><code>Anim.frame</code></a> but for a one-shot clip: the frame is <code>min(floor(timer * fps), count - 1)</code>, so once it reaches the last frame it stays there instead of wrapping. Use it for a play-once animation like an explosion or a door opening; pair it with <a href="anim-finished"><code>Anim.finished</code></a> to know when it is done.

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
    let cell = Anim.once(Blast.timer, 15, 6)
    print(cell)
  }
}
```
