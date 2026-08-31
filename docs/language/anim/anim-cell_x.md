---
id: anim-cell_x
name: Anim.cell_x
category: anim
kind: namespace-method
tokens: Anim.cell_x
sig: Anim.cell_x(frame, cols, cell_w) -> int
tip: The source x (pixels) of a frame on a grid spritesheet.
order: 6
ns: Anim
member: cell_x
---

Turns a frame index into the left pixel of its cell on a spritesheet laid out as a grid of <code>cols</code> columns: <code>(frame mod cols) * cell_w</code>. Combine with <a href="anim-cell_y"><code>Anim.cell_y</code></a> to get the top-left source coordinate to blit from.

Parameters:
- `frame` — the frame index (e.g. from <a href="anim-frame"><code>Anim.frame</code></a>)
- `cols` — columns in the sheet
- `cell_w` — cell width in pixels

```ludic
program Demo {
  handler Run phase Update {
    let f  = Anim.frame(fixed(1), 12, 8)
    let sx = Anim.cell_x(f, 4, 16)
    let sy = Anim.cell_y(f, 4, 16)
    print(sx)
    print(sy)
  }
}
```
