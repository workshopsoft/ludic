---
id: kw-function
name: function
category: structure
kind: keyword
tokens: function
sig: function name(a: T, b: T) -> R { … }
tip: A function — reusable logic called positionally or with named arguments.
order: 8
---

A <code>function</code> declares a function: a reusable block of logic with typed parameters and a return type, written `-> R` (use `-> void` for one that returns nothing). Call it positionally, `heal(2, 10)`, or with named arguments, `heal(amount: 2, maximum: 10)`, which reads more clearly at the call site and is the house style. Functions live at program scope alongside handlers and may be called from any handler; they can `spawn`, run queries, and read program-scope state. Use them to factor out logic shared by several handlers so each handler stays short.

Parameters:
- `a`, `b` — the typed inputs; pass them positionally or by name at the call site

```ludic
program Healer {
  property Health { current: int = 100, maximum: int = 100 }
  model Player { Health }

  function heal(amount: int, maximum: int) -> int {
    let restored = amount * 2
    if restored > maximum { return maximum }
    return restored
  }

  handler Boot phase Start {
    spawn Hero { Health { current: 10, maximum: 100 } }
  }

  handler Recover phase Update {
    for (health) in query [Health, {Player}] {
      health.current = heal(amount: health.current, maximum: health.maximum)
    }
  }
}
```
