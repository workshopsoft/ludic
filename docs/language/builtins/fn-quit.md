---
id: fn-quit
name: quit
category: builtins
kind: builtin
tokens: quit
sig: quit()
tip: Stop the game loop cleanly after the current frame finishes.
order: 2
---

Signals the runtime to stop the game loop after the current frame completes, ending the program in an orderly way. Because it lets the in-progress frame finish, any drawing you have already queued for this frame is still presented. Use it for a "quit to desktop" action, to end a headless test once its work is done, or to stop on a win/lose condition. For an immediate, mid-frame stop with a status code instead, use <code>exit</code>. It takes no arguments.

```ludic
program QuitOnKey {
  handler ReadInput phase Input {
    if Input.key() == 'q' { quit() }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_text(x: 8, y: 8, text: "PRESS Q TO QUIT", color: Color.White, scale: 1)
    Screen.show()
  }
}
```
