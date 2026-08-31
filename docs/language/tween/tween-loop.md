---
id: tween-loop
name: Tween.loop
category: tween
kind: namespace-method
tokens: Tween.loop
sig: Tween.loop(timer, duration) -> fixed
tip: A repeating 0..1 sawtooth amount over duration.
order: 2
ns: Tween
member: loop
---

Returns the fractional part of <code>timer / duration</code> — a sawtooth that ramps <code>0.0</code>→<code>1.0</code> then jumps back to <code>0.0</code> and repeats. Use it for a continuously cycling value: a scrolling offset, a rotating hue, a repeating pulse.

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `duration` — seconds per cycle (a `fixed`)

```ludic
program Demo {
  property Spin { timer: fixed = 0.0 }
  model Coin { Spin }
  handler Run phase Update {
    Spin.timer = Spin.timer + Time.delta()
    let t = Tween.loop(Spin.timer, fixed(2))   # a 2-second cycle
    print(t)
  }
}
```
