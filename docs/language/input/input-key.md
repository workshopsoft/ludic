---
id: input-key
name: Input.key
category: input
kind: namespace-method
tokens: Input.key
sig: Input.key() -> int
tip: The key pressed this frame as a character code (0 when nothing is pressed).
order: 0
ns: Input
member: key
---

Returns the key currently pressed this frame as a character code, or <code>0</code> when no key is down. Compare the result against character literals such as <code>'w'</code>, <code>'a'</code>, <code>'s'</code>, <code>'d'</code>, or <code>' '</code> to drive movement and actions. Read it in an <code>Input</code>-phase handler so input is handled once per frame before the world updates. Because it reports the key held on this frame rather than a one-shot press event, a common pattern for "press to confirm" is to wait until <code>Input.key()</code> returns <code>0</code> (key released) before accepting the next press.

```ludic
program MoveByKey {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 5, row: 5 } }
  }

  handler ReadInput phase Input {
    let pressed = Input.key()
    for (Position) in query [Position, {Player}] {
      if pressed == 'w' { Position.row = Position.row - 1 }
      if pressed == 's' { Position.row = Position.row + 1 }
      if pressed == 'a' { Position.column = Position.column - 1 }
      if pressed == 'd' { Position.column = Position.column + 1 }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Player}] {
      Screen.fill_rectangle(
        x: Position.column * TILE_SIZE,
        y: Position.row * TILE_SIZE,
        width: TILE_SIZE,
        height: TILE_SIZE,
        color: Color.LimeGreen)
    }
    Screen.show()
  }
}
```
