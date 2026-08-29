---
id: math-wrap
name: Math.wrap
category: math
kind: namespace-method
tokens: Math.wrap
sig: Math.wrap(v, lo, hi) -> int
tip: Wrap a value into the range [lo, hi).
order: 21
ns: Math
member: wrap
---

Wraps <code>v</code> into the half-open range <code>lo</code>..<code>hi</code>, so values that run off one end reappear at the other — the toroidal counterpart to <code>Math.clamp</code>. Use it for wrap-around movement, cycling through a menu, or keeping a scrolling offset in bounds.

```ludic
program Demo {
  handler Step phase Update {
    let x = Math.wrap(player_x, 0, world_width)
  }
}
```
