---
id: screen-width
name: Screen.width
category: screen
kind: namespace-method
tokens: Screen.width
sig: Screen.width() -> int
tip: The framebuffer width in pixels.
order: 7
ns: Screen
member: width
---

Returns the width of the framebuffer in pixels — the number of drawable columns. Use it to lay out and center content relative to the actual screen size rather than hard-coding a fixed number, so your HUD or menu stays positioned correctly if the resolution changes. It pairs with <code>Screen.height</code> for full-screen calculations such as clamping a moving object inside the visible area. It takes no arguments and can be read during any handler.

```ludic
program CenteredLabel {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    let label_width = 10 * 6
    let centered_x = (Screen.width() - label_width) / 2
    Screen.draw_text(x: centered_x, y: 40, text: "CHRONORIFT", color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
