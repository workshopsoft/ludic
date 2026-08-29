---
id: kw-match
name: match
category: control
kind: keyword
tokens: match
sig: match value { 0, 1 => … _ => … }
tip: Multi-way branch on one value, matching one or more literals per arm.
order: 4
---

A <code>match</code> replaces an `if`/`else` ladder that tests one value against several constants. It evaluates the subject once, then takes the first arm whose pattern matches; an arm lists one or more literal patterns separated by commas and points at a body with `=>`, and a lone `_` arm is the catch-all default. Patterns are compile-time constants — integers, char literals like `'w'`, or `enum` variants such as `Action.Guard` — which makes `match` ideal for dispatching on a key press, a tile code, or a mode. Each arm's body is a single statement or a `{ … }` block; matching lowers to plain branches, so it is as cheap as the `if` chain it replaces.

```ludic
program Steering {
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Player { Velocity }

  handler Boot phase Start {
    spawn Hero { Velocity { delta_x: 0, delta_y: 0 } }
  }

  handler ReadKeys phase Input {
    let pressed = Input.key()
    for (velocity) in query [Velocity, {Player}] {
      match pressed {
        'w' => velocity.delta_y = -1
        's' => velocity.delta_y = 1
        'a', 'h' => velocity.delta_x = -1
        'd', 'l' => velocity.delta_x = 1
        _ => velocity.delta_x = 0
      }
    }
  }
}
```
