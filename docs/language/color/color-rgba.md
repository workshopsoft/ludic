---
id: color-rgba
name: Color.rgba
category: color
kind: namespace-method
tokens: Color.rgba
sig: Color.rgba(r, g, b, a) -> int
tip: Build a color with an alpha byte.
order: 1
ns: Color
member: rgba
---

Packs <code>r</code>, <code>g</code>, <code>b</code>, and an alpha <code>a</code> (0..255) into a <code>0xAARRGGBB</code> int. The software renderer draws opaque, but the alpha byte is preserved for your own blending or storage.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let c = Color.rgba(255, 128, 64, 200)
    Screen.clear(c)
    Screen.show()
  }
}
```
