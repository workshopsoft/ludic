---
id: tween-point
name: Tween.point
category: tween
kind: namespace-method
tokens: Tween.point
sig: Tween.point(from, to, t) -> Vector
tip: Component-wise blend of two Vectors by amount t.
order: 8
ns: Tween
member: point
---

Interpolates two <a href="vector"><code>Vector</code></a> endpoints component-wise by amount <code>t</code> — the 2D version of <a href="tween-number"><code>Tween.number</code></a>. Move an entity along a straight path, or ease a camera toward a target, in one call.

Parameters:
- `from` — the point at `t = 0` (a `Vector`)
- `to` — the point at `t = 1` (a `Vector`)
- `t` — the blend amount (a `fixed`, usually 0..1)

```ludic
program Demo {
  handler Run phase Update {
    let a = Vector.make(fixed(0), fixed(0))
    let b = Vector.make(fixed(100), fixed(40))
    let t = Tween.progress(fixed(1), fixed(2))
    let p = Tween.point(a, b, Tween.ease(t, 3))
    print(Vector.x(p))
  }
}
```
