---
id: input-cursor_mode
name: Input.cursor_mode
category: input
kind: namespace-method
tokens: Input.cursor_mode
sig: Input.cursor_mode(mode)
tip: Hide / lock / confine the OS mouse cursor to the window (windowed).
order: 36
ns: Input
member: cursor_mode
---

Sets how a windowed game captures the OS mouse cursor:

- <code>0</code> normal (default) — the cursor is visible and free.
- <code>1</code> hidden — the cursor is hidden while the window is focused, so a game can draw its own reticle.
- <code>2</code> locked — hidden and dissociated from the mouse; the mouse feeds <em>relative</em> motion through <a href="input-mouse_dx.html"><code>Input.mouse_dx</code></a> / <code>mouse_dy</code>, and <a href="input-mouse_x.html"><code>Input.mouse_x</code></a> / <code>mouse_y</code> is a clamped virtual cursor — the FPS / twin-stick aim mode.
- <code>3</code> confined — dissociated but visible; the mouse cannot leave the window.

The platform **auto-releases** (shows the cursor and reconnects it) while the window is not the key window (Cmd-Tab), and restores it on window close, so the cursor is never left captured. On a headless / non-windowed build it is a no-op.

```ludic
program Aim {
  property Tag { n: int = 0 }
  model P { Tag }
  @OnStart handler Boot { Input.cursor_mode(2) }     # lock + hide for aiming
  handler Draw phase Render {
    Screen.clear(0x101018)
    Screen.fill_rectangle(Input.mouse_x() - 2, Input.mouse_y() - 2, 4, 4, 0xffcc00)
    Screen.show()
  }
}
```
