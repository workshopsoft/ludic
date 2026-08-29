---
id: ease-in_out
name: Ease.in_out
category: ease
kind: namespace-method
tokens: Ease.in_out
sig: Ease.in_out(t) -> fixed
tip: Ease in and then out (smoothstep).
order: 2
ns: Ease
member: in_out
---

Returns the smooth <code>3t^2 - 2t^3</code> S-curve: slow at both ends, fastest in the middle. Use it for a polished there-and-back or point-to-point move that neither jerks off the mark nor slams into the target.

```ludic
program Demo {
  handler Step phase Update {
    let a = Math.lerp(0.0, 1.0, Ease.in_out(progress))
  }
}
```
