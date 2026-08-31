---
id: fn-is_some
name: is_some
category: builtins
kind: builtin
tokens: is_some
sig: is_some(o: option) -> bool
tip: True when an option holds a value.
order: 18
---

Returns true when an <code>option</code> holds a value (it is <a href="fn-some"><code>some</code></a>, not <a href="fn-none"><code>none</code></a>) — the guard before acting on an optional target or slot.

Parameters:
- `o` — the option to test

```ludic
program AI {
  handler Step phase Update {
    let target = none()
    if is_some(target) { chase(unwrap_or(target, 0)) }
  }
}
```
