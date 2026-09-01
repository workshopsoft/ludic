---
id: promise-race
name: Promise.race
category: promise
kind: namespace-method
tokens: Promise.race
sig: Promise.race(handles) -> Job
tip: Succeeds when the first member does.
order: 1
ns: Promise
member: race
---

Succeeds when the first member does.

```ludic
let hs = new []int
push(hs, a)
push(hs, b)
let first = Promise.race(hs)
```
