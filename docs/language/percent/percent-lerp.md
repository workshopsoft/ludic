---
id: percent-lerp
name: Percent.lerp
category: percent
kind: namespace-method
tokens: Percent.lerp
sig: Percent.lerp(a, b, t) -> fixed
tip: Interpolate a..b by a clamped t.
order: 2
ns: Percent
member: lerp
---

Interpolates from <code>a</code> to <code>b</code> by <code>t</code>, clamping <code>t</code> to [0, 1] first so the result never overshoots the endpoints.

```ludic
program Demo {
  handler Step phase Update {
    let x = Percent.lerp(startX, endX, progress)
  }
}
```
