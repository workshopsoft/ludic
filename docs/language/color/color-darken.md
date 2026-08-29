---
id: color-darken
name: Color.darken
category: color
kind: namespace-method
tokens: Color.darken
sig: Color.darken(c, amount) -> int
tip: Scale a color toward black.
order: 3
ns: Color
member: darken
---

Multiplies each channel of <code>c</code> by <code>1 - amount</code> (amount a fixed 0..1), returning a darker color. <code>Color.darken(c, 0.0)</code> is unchanged and <code>1.0</code> is black. Handy for shadows and pressed-button states.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let c = Color.darken(Color.Red, 0.3)
    Screen.clear(c)
    Screen.show()
  }
}
```
