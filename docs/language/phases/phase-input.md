---
id: phase-input
name: Input
category: phases
kind: phase
tokens: Input
sig: phase Input
tip: The first per-frame phase — read the keyboard and record the player's intent.
order: 1
---

`Input` is the first phase of every frame. The runtime polls the keyboard just before it runs, so a `handler … phase Input` reads the current key with `Input.key()` and turns it into intent — a chosen direction, a menu selection, a pause toggle — usually by writing a program `var` that later phases act on. Keep it to <b>reading input and recording decisions</b>: do the actual movement and simulation in `FixedUpdate`/`Update`, and the drawing in `Render`. Because it runs before `FixedUpdate`, `Update`, `LateUpdate`, and `Render`, the intent it records is visible to every phase in the same frame.

```ludic
program InputExample {
  const DIRECTION_LEFT: int = 0
  const DIRECTION_RIGHT: int = 1
  state InputExampleState {
    facing: int = DIRECTION_RIGHT
  }

  handler ReadControls(input_example_st: mut InputExampleState) phase Input {
    let pressed_key = Input.key()
    if pressed_key == 'a' { input_example_st.facing = DIRECTION_LEFT }
    if pressed_key == 'd' { input_example_st.facing = DIRECTION_RIGHT }
  }

  handler DrawWorld(input_example_st: InputExampleState) phase Render {
    Screen.clear(Color.MidnightBlue)
    var marker_x = 40
    if input_example_st.facing == DIRECTION_RIGHT { marker_x = 200 }
    Screen.fill_rectangle(x: marker_x, y: 100, width: 16, height: 16, color: Color.LimeGreen)
    Screen.show()
  }
}
```
