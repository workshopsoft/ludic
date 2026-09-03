---
id: input-move_i
name: Input.move_i
category: input
kind: namespace-method
tokens: Input.move_i
sig: Input.move_i() -> IVec2
tip: The standard top-down movement intent, -1/0/1 per axis.
order: 60
ns: Input
member: move_i
---

WASD or the arrow keys, and the left stick of pad 0 (past a 0.35 deadzone) when one is connected, as an <code>IVec2</code> of -1, 0 or 1 per axis — what a top-down mover feeds <code>TopDown.move</code>.

```ludic
# doc-check: skip — illustrative
let move = Input.move_i()
TopDown.move(player, move.x, move.y)
```
