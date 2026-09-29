---
id: kw-reducer
name: reducer
category: structure
kind: keyword
tokens: reducer
sig: reducer State on Action(st: mut State, reads..., a: Action) { ... }
tip: Applies an action to one state; it may read others.
order: 62
---

A <code>reducer</code> writes exactly one state when its action is dispatched: the first parameter is that state, <code>mut</code>, the last is the action, and any states between are read-only. A change that must touch several states in a set order is a chain: a reducer dispatches the next action.

```ludic
state Pos { x: int = 0 }
action Move { dx: int = 0 }
reducer Pos on Move(p: mut Pos, a: Move) {
  p.x = p.x + a.dx
}
```
