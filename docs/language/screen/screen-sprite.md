---
id: screen-sprite
name: Screen.sprite
category: screen
kind: namespace-method
tokens: Screen.sprite
sig: Screen.sprite(id, x, y)
tip: Blit a sprite at its natural size.
order: 15
ns: Screen
member: sprite
---

Draws sprite <code>id</code> from the loaded sprite sheet at <code>(x, y)</code>, at its natural 16x16 size. Load the sheet once at start, then draw sprites each frame during <code>Render</code>.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.sprite(id: hero_frame, x: px, y: py)
    Screen.show()
  }
}
```
