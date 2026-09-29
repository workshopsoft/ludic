---
id: kw-mut
name: mut
category: structure
kind: keyword
tokens: mut
sig: function f(st: mut State)
tip: A parameter the function may change - how a state is written.
order: 58
---

A state reaches a function only as a parameter: <code>h: HikerState</code> to read it, <code>h: mut HikerState</code> to change it, so a function's signature is everything it touches. The compiler refuses a write through a parameter that is not <code>mut</code>, and <code>ludic migrate state --tighten</code> takes <code>mut</code> off every one nothing down the chain writes.

```ludic
state Counter { n: int = 0 }
function bump(c: mut Counter) -> void { c.n = c.n + 1 }
```
