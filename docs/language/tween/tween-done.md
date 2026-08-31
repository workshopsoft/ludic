---
id: tween-done
name: Tween.done
category: tween
kind: namespace-method
tokens: Tween.done
sig: Tween.done(timer, duration) -> bool
tip: True once a one-shot tween's timer reaches its duration.
order: 4
ns: Tween
member: done
---

Returns <code>true</code> once <code>timer >= duration</code> — the companion to <a href="tween-progress"><code>Tween.progress</code></a> for ending a one-shot tween: kick off the next step, clear a component, or snap the value to its target.

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `duration` — the tween's length in seconds (a `fixed`)

```ludic
program Demo {
  property Slide { timer: fixed = 0.0 }
  model Menu { Slide }
  handler Run phase Update {
    Slide.timer = Slide.timer + Time.delta()
    if Tween.done(Slide.timer, fixed(1)) { print(1) }
  }
}
```
