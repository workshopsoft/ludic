---
id: kw-component
name: component
category: structure
kind: keyword
tokens: component
sig: component Name[(states)] { prop p: T = v, state s: T = v, function ..., on e(...) { } }
tip: A UI component: its props, state, functions and events, beside Name.xml and Name.lss.
order: 70
---

A <code>component</code> is a piece of interface: the code file declares its <code>prop</code>s (handed in by its parent), its own <code>state</code>, the functions its template calls and the events it handles with <code>on</code>; <code>Name.xml</code> beside it is its template and <code>Name.lss</code> its styles. The states named in its header are supplied by the runtime and never seen by the template.

```ludic
# doc-check: skip — a component needs its template beside it
component Counter {
  prop step: int = 1
  state count: int = 0
  on add() { count = count + step }
}
```
