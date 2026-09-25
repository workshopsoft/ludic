---
id: screen-status
name: Screen.status
category: screen
kind: namespace-method
tokens: Screen.status
sig: Screen.status(text)
tip: Set the persistent one-line status/HUD string shown by the runtime.
order: 9
ns: Screen
member: status
---

Sets a single persistent line of status text that the runtime displays outside your normal drawing — a lightweight HUD line for debugging or a title-bar style message. Unlike <code>Screen.draw_text</code>, it is not part of the framebuffer you clear and present each frame: you set it once (or whenever it changes) and it persists until you set it again. Use it for coarse status such as the current level, connection state, or a frame-rate readout while iterating. It takes a single string argument.

Parameters:
- `text` — the status line to display

```ludic
program StatusLine {
  state StatusLineState {
    elapsed_frames: int = 0
  }

  handler UpdateStatus(status_line_st: mut StatusLineState) phase Update {
    status_line_st.elapsed_frames = status_line_st.elapsed_frames + 1
    Screen.status(text: `frame {status_line_st.elapsed_frames}`)
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.show()
  }
}
```
