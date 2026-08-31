---
id: tween-yoyo
name: Tween.yoyo
category: tween
kind: namespace-method
tokens: Tween.yoyo
sig: Tween.yoyo(timer, duration) -> fixed
tip: A repeating 0..1..0 triangle amount over duration.
order: 3
ns: Tween
member: yoyo
---

Returns a triangle wave: <code>timer / duration</code> ramps <code>0.0</code>→<code>1.0</code> over the first <code>duration</code>, then <code>1.0</code>→<code>0.0</code> over the next, and repeats. The smooth back-and-forth for a hover bob, a pulsing highlight, or a breathing scale — no snap at the ends the way <a href="tween-loop"><code>Tween.loop</code></a> has.

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `duration` — seconds for each leg (a `fixed`)

```ludic
program Demo {
  property Bob { timer: fixed = 0.0 }
  model Pickup { Bob }
  handler Run phase Update {
    Bob.timer = Bob.timer + Time.delta()
    let t = Tween.yoyo(Bob.timer, fixed(1))
    let y = Tween.round(100, 108, Tween.ease(t, 3))
    print(y)
  }
}
```
