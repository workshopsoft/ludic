---
id: kw-while
name: while
category: control
kind: keyword
tokens: while
sig: while cond { … }
tip: Loop as long as a condition holds, re-checking it before each pass.
order: 1
---

A <code>while</code> loop re-evaluates its condition before every pass and runs the body as long as it stays true, so it is the tool when the number of iterations is not known up front. As with `if`, the condition needs no parentheses and the braces are required. `break` leaves the loop immediately and `continue` jumps to the next condition check. When you are simply counting over a fixed range, prefer the numeric `for i in a .. b` loop, which is clearer and binds a fresh index for you; reach for `while` when the step or the stopping test is irregular.

```ludic
program Countdown {
  var fuse: int = 5
  var elapsed_frames: int = 0

  handler Tick phase Update {
    elapsed_frames = elapsed_frames + 1
    while fuse > 0 and elapsed_frames % 60 == 0 {
      fuse = fuse - 1
      elapsed_frames = elapsed_frames + 1
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 8, y: 8, value: fuse, color: Color.Crimson, scale: 3)
    Screen.show()
  }
}
```
