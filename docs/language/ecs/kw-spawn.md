---
id: kw-spawn
name: spawn
category: ecs
kind: keyword
tokens: spawn
sig: spawn Label { Prop { field: v }; … }
tip: Create an entity carrying the listed properties (or a model).
order: 0
---

Create an entity carrying the listed properties (or a model). The label is for readability.

```ludic
spawn Body { Seg { order: 1 }; Pos { x: 9, y: 7 } }
```
