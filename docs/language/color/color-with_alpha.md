---
id: color-with_alpha
name: Color.with_alpha
category: color
kind: namespace-method
tokens: Color.with_alpha
sig: Color.with_alpha(c, a) -> int
tip: Replace a color's alpha byte.
order: 5
ns: Color
member: with_alpha
---

Returns <code>c</code> with its alpha byte set to <code>a</code> (0..255), leaving the RGB channels untouched.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let c = Color.with_alpha(Color.Green, 128)
    Screen.clear(c)
    Screen.show()
  }
}
```
