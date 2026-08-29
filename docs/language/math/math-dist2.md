---
id: math-dist2
name: Math.dist2
category: math
kind: namespace-method
tokens: Math.dist2
sig: Math.dist2(x0, y0, x1, y1) -> fixed
tip: Squared distance between two points.
order: 17
ns: Math
member: dist2
---

Returns the squared distance between <code>(x0, y0)</code> and <code>(x1, y1)</code> — <code>dx*dx + dy*dy</code>, with no square root. Comparing squared distances gives the same ordering as comparing real distances, so this is the cheaper choice for "nearest" and "within radius" tests: compare against <code>radius * radius</code> instead of calling <code>Math.dist</code>.

```ludic
program Demo {
  handler Step phase Update {
    let r2 = radius * radius
    if Math.dist2(px, py, ex, ey) < r2 { in_range() }
  }
}
```
