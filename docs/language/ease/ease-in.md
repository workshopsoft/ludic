---
id: ease-in
name: Ease.in
category: ease
kind: namespace-method
tokens: Ease.in
sig: Ease.in(t) -> fixed
tip: Accelerate from rest (quadratic ease-in).
order: 0
ns: Ease
member: in
---

Returns <code>t * t</code> — motion that starts slow and speeds up. Feed the result to <code>Math.lerp</code> as the blend amount so a value accelerates into its target. The input <code>t</code> is expected in <code>0.0</code>..<code>1.0</code>.

```ludic
program Demo {
  handler Step phase Update {
    let x = Math.lerp(start_x, end_x, Ease.in(progress))
  }
}
```
