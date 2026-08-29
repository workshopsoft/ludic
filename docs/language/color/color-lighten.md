---
id: color-lighten
name: Color.lighten
category: color
kind: namespace-method
tokens: Color.lighten
sig: Color.lighten(c, amount) -> int
tip: Scale a color toward white.
order: 4
ns: Color
member: lighten
---

Moves each channel of <code>c</code> a fraction <code>amount</code> of the way to 255, returning a lighter color — the counterpart to <code>Color.darken</code>. Good for highlights and hover states.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let c = Color.lighten(Color.Blue, 0.3)
    Screen.clear(c)
    Screen.show()
  }
}
```
