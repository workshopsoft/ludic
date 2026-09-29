---
id: kw-internal
name: internal
category: structure
kind: keyword
tokens: internal
sig: namespace Name { internal function helper() { } }
tip: Inside a namespace: a function kept out of the Name.* surface.
order: 55
---

In a <code>namespace</code> block every function is part of the <code>Name.*</code> surface unless it says <code>internal</code>: then it is emitted as an ordinary helper the namespace's own methods can call, and <code>Name.helper</code> is not a method.

```ludic
namespace Trail {
  internal function step(n: int) -> int { return n + 1 }
  function next(n: int) -> int { return step(n) }
}
```
