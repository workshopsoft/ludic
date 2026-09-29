---
id: kw-dispatch
name: dispatch
category: control
kind: keyword
tokens: dispatch
sig: dispatch Action(field: value, ...)
tip: Queues an action for the reducers declared on it.
order: 13
---

<code>dispatch Move(dx: 1)</code> queues an action; at the end of the frame phase every <code>reducer</code> on <code>Move</code> applies it to its own state, in the order of the states' names. Input code and a screen's buttons dispatch; they never write another module's state.

```ludic
# doc-check: skip — the action is declared elsewhere
dispatch Move(dx: 1)
```
