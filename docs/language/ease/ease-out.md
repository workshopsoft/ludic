---
id: ease-out
name: Ease.out
category: ease
kind: namespace-method
tokens: Ease.out
sig: Ease.out(t) -> fixed
tip: Decelerate to rest (quadratic ease-out).
order: 1
ns: Ease
member: out
---

Returns <code>t * (2 - t)</code> — motion that starts fast and slows as it arrives. The most natural-feeling easing for things settling into place, like a panel sliding in or a camera coming to rest.

```ludic
program Demo {
  handler Step phase Update {
    let y = Math.lerp(top, rest_y, Ease.out(progress))
  }
}
```
