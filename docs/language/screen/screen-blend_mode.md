---
id: screen-blend_mode
name: Screen.blend_mode
category: screen
kind: namespace-method
tokens: Screen.blend_mode
sig: Screen.blend_mode(mode)
tip: Choose replace or additive pixel blending.
order: 21
ns: Screen
member: blend_mode
---

Selects how drawn pixels combine with the framebuffer: <code>0</code> replaces (the default), <code>1</code> adds colours channel-wise and clamps at 255. Additive blending is how you draw glows, fire, lasers, and light — stack several bright shapes and the overlaps brighten toward white. Set it back to <code>0</code> when done.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.blend_mode(1)
    Screen.fill_circle(x: 150, y: 120, radius: 30, color: Color.rgb(80, 20, 0))
    Screen.fill_circle(x: 170, y: 120, radius: 30, color: Color.rgb(80, 20, 0))
    Screen.blend_mode(0)
    Screen.show()
  }
}
```
