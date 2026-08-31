---
id: tween-progress
name: Tween.progress
category: tween
kind: namespace-method
tokens: Tween.progress
sig: Tween.progress(timer, duration) -> fixed
tip: A one-shot 0..1 amount, clamped, for timer over duration.
order: 1
ns: Tween
member: progress
---

Returns <code>timer / duration</code> clamped to <code>0.0</code>..<code>1.0</code> — the normalized progress of a one-shot tween. Feed it to <a href="tween-ease"><code>Tween.ease</code></a> to shape it, then to a typed blend. Once <code>timer</code> reaches <code>duration</code> it pins at <code>1.0</code> (a non-positive <code>duration</code> also reads as done).

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `duration` — the tween's length in seconds (a `fixed`)

```ludic
program Demo {
  property Fade { timer: fixed = 0.0 }
  model Panel { Fade }
  handler Run phase Update {
    Fade.timer = Fade.timer + Time.delta()
    let t = Tween.progress(Fade.timer, fixed(1))
    let a = Tween.round(0, 255, Tween.ease(t, 2))
    print(a)
  }
}
```
