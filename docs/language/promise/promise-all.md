---
id: promise-all
name: Promise.all
category: promise
kind: namespace-method
tokens: Promise.all
sig: Promise.all(handles) -> Job
tip: Succeeds when every member succeeds.
order: 0
ns: Promise
member: all
---

Succeeds when every member succeeds.

```ludic
let hs = new []int
push(hs, a)
push(hs, b)
let loaded = Promise.all(hs)
```
