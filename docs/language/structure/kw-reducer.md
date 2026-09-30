---
id: kw-reducer
name: reducer
category: structure
kind: keyword
tokens: reducer
sig: reducer State on Action(st: mut State, reads..., a: Action) { ... }  /  reducer Record in State.table on Action(r: mut Row<Record>, reads..., a: Action) { ... }
tip: Applies an action to one state, or to the one table row its @Target names; it may read others.
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

Written <code>in State.table</code>, a reducer runs for the one row of that <code>Table&lt;Record&gt;</code> the action's <code>@Target</code> field names: it is handed a <code>Row&lt;Record&gt;</code>, reaches <code>r.rec</code> and <code>r.h</code>, and changes a field a column mirrors (<code>@Column</code>) only through a <code>@RowVerb</code>. A handle whose row is gone runs nothing.

```ludic
# doc-check: skip — needs ludic.base's Table
reducer Deer in Herd.deer on Spook(r: mut Row<Deer>, a: Spook) {
  r.rec.fear += a.by
}
```
