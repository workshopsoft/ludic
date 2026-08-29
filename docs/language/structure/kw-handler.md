---
id: kw-handler
name: handler
category: structure
kind: keyword
tokens: handler
sig: handler Name phase P { … }
tip: A block of code the engine runs every frame during phase P.
order: 3
---

A block of code the engine runs every frame during phase <code>P</code>. With a query, the body runs once per matching entity.

```ludic
handler Move phase Update { … }
```
