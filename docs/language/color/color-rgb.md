---
id: color-rgb
name: Color.rgb
category: color
kind: namespace-method
tokens: Color.rgb
sig: Color.rgb(r, g, b) -> int
tip: Build a color from red, green, blue.
order: 0
ns: Color
member: rgb
---

Packs three 0..255 channel values into a single <code>0xRRGGBB</code> color int. Use it to build a color from computed channels rather than a fixed literal or a palette name.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let c = Color.rgb(255, 128, 64)
    Screen.clear(c)
    Screen.show()
  }
}
```
