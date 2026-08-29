---
id: kw-self
name: self
category: ecs
kind: keyword
tokens: self
sig: self()
tip: The model instance currently bound by the enclosing query loop.
order: 3
---

<code>self()</code> yields the model instance currently being visited by the innermost enclosing `query` loop, as an `entity` handle. It is how a handler names "the instance this pass is about" — most often to `despawn self()`, to `attach`/`detach` a property `on self()`, or to pass the current instance to a function. Because it depends on the active query iteration, `self()` is only meaningful inside a `for (…) in query […]` loop (or a `@Queries` handler, which desugars to one). Outside any query it has no instance to refer to.

```ludic
program Reaper {
  property Position { column: int = 0, row: int = 0 }
  property Health   { current: int = 100, maximum: int = 100 }
  model Enemy { Position, Health }

  handler Boot phase Start {
    spawn Grunt { Position { column: 1, row: 1 }; Health { current: 0 } }
  }

  handler RemoveDefeated phase LateUpdate {
    for (health) in query [Health, {Enemy}] {
      if health.current <= 0 { despawn self() }
    }
  }
}
```
