---
id: reflect-model
name: Reflect.model
category: reflect
kind: namespace-method
tokens: Reflect.model
sig: Reflect.model(name) -> int
tip: The model id for a model name, or -1 if unknown.
order: 12
ns: Reflect
member: model
---

Resolves a model (archetype) name to its id, or <code>-1</code> if no such model exists. The counterpart to <a href="reflect-kind"><code>Reflect.kind</code></a>: resolve the name once, then compare entities' kinds against it.

Parameters:
- `name` — the model name

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    print(Reflect.model("Unit"))
  }
}
```
