---
id: screen-measure_text
name: Screen.measure_text
category: screen
kind: namespace-method
tokens: Screen.measure_text
sig: Screen.measure_text(text) -> int
tip: The pixel advance width of text in the built-in font.
order: 22
ns: Screen
member: measure_text
---

Returns the width in pixels that <code>text</code> occupies in the built-in 5x7 font at scale 1 — 6 pixels per glyph, matching how <a href="screen-draw_text"><code>Screen.draw_text</code></a> advances. Use it to right-align or centre text, size a label's background, or lay out a menu.

```ludic
program Demo {
  handler DrawWorld phase Render {
    let label = "READY"
    let w = Screen.measure_text(label)
    Screen.draw_text(x: 160 - w / 2, y: 100, text: label, color: Color.White, scale: 1)
    Screen.show()
  }
}
```
