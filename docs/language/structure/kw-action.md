---
id: kw-action
name: action
category: structure
kind: keyword
tokens: action
sig: action Name { field: Type, ... }
tip: What the player asked for, dispatched and applied by each state's reducer.
order: 61
---

An <code>action</code> is a record that says what was asked for in the game's words (<code>Move</code>, <code>OpenPack</code>). Input code <code>dispatch</code>es it, and every <code>reducer</code> declared on it changes its own state. The queue drains at the end of every frame phase, each action's reducers in the order of their states' names.

```ludic
action Move { dx: int = 0, dy: int = 0 }
```
