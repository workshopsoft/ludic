---
id: screen-sprite_scaled
name: Screen.sprite_scaled
category: screen
kind: namespace-method
tokens: Screen.sprite_scaled
sig: Screen.sprite_scaled(id, x, y, scale)
tip: Blit a sprite at an integer scale.
order: 16
ns: Screen
member: sprite_scaled
---

Draws sprite <code>id</code> at <code>(x, y)</code> enlarged by an integer <code>scale</code> (2 doubles it, and so on) — for chunky pixel-art zoom without blurring.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.sprite_scaled(id: boss, x: bx, y: by, scale: 3)
    Screen.show()
  }
}
```
