---
id: math-dist
name: Math.dist
category: math
kind: namespace-method
tokens: Math.dist
sig: Math.dist(x0, y0, x1, y1) -> fixed
tip: Distance between two points.
order: 16
ns: Math
member: dist
---

Returns the straight-line distance between <code>(x0, y0)</code> and <code>(x1, y1)</code> — <code>sqrt(dx*dx + dy*dy)</code> in fixed-point. Use it for proximity and range checks. When you only need to compare distances (which is nearer? within radius?), prefer <code>Math.dist2</code>, which skips the square root.

```ludic
program Demo {
  handler Step phase Update {
    if Math.dist(px, py, ex, ey) < attack_range { strike() }
  }
}
```
