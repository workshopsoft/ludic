---
id: kw-machine
name: machine
category: control
kind: keyword
tokens: machine
sig: machine store { state Name { … } }
tip: A state machine over an int var (or register).
order: 6
---

A state machine over an int <code>var</code> (or register). It dispatches on the store's value.

```ludic
machine turn_phase { state KnightMenu { … } }
```
