---
id: math-lerp
name: Math.lerp
category: math
kind: namespace-method
tokens: Math.lerp
sig: Math.lerp(a, b, t) -> fixed
tip: Blend between two values by a 0..1 amount.
order: 8
ns: Math
member: lerp
---

Linear interpolation: returns <code>a</code> when <code>t</code> is <code>0.0</code>, <code>b</code> when <code>t</code> is <code>1.0</code>, and a proportional blend in between — the exact value <code>a + (b - a) * t</code>. All three arguments are <code>fixed</code> and the result is <code>fixed</code>. It is the workhorse behind smooth motion: ease a camera toward a target, fade a value over time, or sample a gradient. Values of <code>t</code> outside <code>0..1</code> extrapolate past the endpoints.

Parameters:
- `a` — the value returned at `t = 0.0`
- `b` — the value returned at `t = 1.0`
- `t` — the blend amount, normally `0.0`..`1.0`

```ludic
program EaseCamera {
  var camera_x: fixed = 0.0
  var target_x: fixed = 100.0

  handler Follow phase Update {
    camera_x = Math.lerp(camera_x, target_x, 0.1)   # glides a tenth of the way each frame
  }
}
```
