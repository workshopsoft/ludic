---
id: color-lerp
name: Color.lerp
category: color
kind: namespace-method
tokens: Color.lerp
sig: Color.lerp(c0, c1, t) -> int
tip: Blend between two colors.
order: 2
ns: Color
member: lerp
---

Interpolates each channel of <code>c0</code> and <code>c1</code> by the fixed amount <code>t</code> in <code>0.0</code>..<code>1.0</code>, returning the blended color. Use it for gradients, fades between two tints, or a flash that returns to base.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let c = Color.lerp(Color.Black, Color.White, 0.5)
    Screen.clear(c)
    Screen.show()
  }
}
```
