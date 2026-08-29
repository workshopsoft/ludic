---
id: kw-for
name: for … in
category: control
kind: keyword
tokens: for
sig: for name in a .. b { … }
tip: Range loop — iterate the half-open range from a up to but not including b.
order: 2
---

The numeric <code>for … in</code> loop walks the half-open range `a .. b`, running the body for each value from `a` up to <b>but not including</b> `b`. <b>Each pass binds a fresh, immutable <code>name</code></b> — it is not a reusable variable and cannot be reassigned inside the body — which makes the loop easy to reason about. Both bounds are ordinary expressions, so ranges built from constants like `0 .. GRID_WIDTH` read cleanly. The same `for … in` keyword also drives ECS query loops (`for (…) in query […]`); this page is the numeric range form. Use `break` and `continue` to exit early or skip to the next value.

```ludic
program Grid {
  const GRID_WIDTH: int = 20
  const GRID_HEIGHT: int = 15
  const TILE_SIZE: int = 16

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for row in 0 .. GRID_HEIGHT {
      for column in 0 .. GRID_WIDTH {
        var tile_color = Color.MidnightBlue
        if (column + row) % 2 == 0 { tile_color = Color.White }
        Screen.fill_rectangle(x: column * TILE_SIZE, y: row * TILE_SIZE, width: TILE_SIZE, height: TILE_SIZE, color: tile_color)
      }
    }
    Screen.show()
  }
}
```
