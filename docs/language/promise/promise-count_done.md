---
id: promise-count_done
name: Promise.count_done
category: promise
kind: namespace-method
tokens: Promise.count_done
sig: Promise.count_done(handles) -> int
tip: How many members have resolved.
order: 2
ns: Promise
member: count_done
---

How many members have resolved.

```ludic
let hs = new []int
push(hs, a)
push(hs, b)
let progress = Promise.count_done(hs)
```
