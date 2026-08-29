---
id: kw-return
name: return
category: structure
kind: keyword
tokens: return
sig: return value
tip: Hand a value back from a function and stop running it.
order: 9
---

A <code>return</code> statement ends the current function and hands its result back to the caller. Its value must match the function's declared return type; in a `-> void` function you write a bare `return` (or simply let the body end) to exit early. `return` is often paired with an early guard — check a condition and return straight away — which keeps the common path unindented. Inside a handler's query loop, prefer `break` or `continue` to control the loop; `return` leaves the whole function.

```ludic
program Clamp {
  property Health { current: int = 100, maximum: int = 100 }
  model Player { Health }

  function clamp_current(value: int, maximum: int) -> int {
    if value < 0 { return 0 }
    if value > maximum { return maximum }
    return value
  }

  handler Boot phase Start {
    spawn Hero { Health { current: 250, maximum: 100 } }
  }

  handler Normalize phase Update {
    for (health) in query [Health, {Player}] {
      health.current = clamp_current(value: health.current, maximum: health.maximum)
    }
  }
}
```
