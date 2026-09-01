---
id: promise-all_done
name: Promise.all_done
category: promise
kind: namespace-method
tokens: Promise.all_done
sig: Promise.all_done(handles) -> bool
tip: Have all members resolved?
order: 3
ns: Promise
member: all_done
---

Have all members resolved?

```ludic
let hs = new []int
push(hs, a)
push(hs, b)
let ready = Promise.all_done(hs)
```
