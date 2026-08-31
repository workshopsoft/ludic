---
id: anim-cell_y
name: Anim.cell_y
category: anim
kind: namespace-method
tokens: Anim.cell_y
sig: Anim.cell_y(frame, cols, cell_h) -> int
tip: The source y (pixels) of a frame on a grid spritesheet.
order: 7
ns: Anim
member: cell_y
---

Turns a frame index into the top pixel of its cell on a spritesheet laid out as a grid of <code>cols</code> columns: <code>(frame / cols) * cell_h</code>. Pair with <a href="anim-cell_x"><code>Anim.cell_x</code></a> for the full source rectangle of the frame.

Parameters:
- `frame` — the frame index (e.g. from <a href="anim-frame"><code>Anim.frame</code></a>)
- `cols` — columns in the sheet
- `cell_h` — cell height in pixels

```ludic
program Demo {
  handler Run phase Update {
    let f  = Anim.frame(fixed(1), 12, 8)
    let sy = Anim.cell_y(f, 4, 16)
    print(sy)
  }
}
```
