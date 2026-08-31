---
id: fn-is_none
name: is_none
category: builtins
kind: builtin
tokens: is_none
sig: is_none(o: option) -> bool
tip: True when an option is empty.
order: 19
---

Returns true when an <code>option</code> is empty (it is <a href="fn-none"><code>none</code></a>). The complement of <a href="fn-is_some"><code>is_some</code></a>.

Parameters:
- `o` — the option to test

```ludic
program AI {
  handler Step phase Update {
    let target = none()
    if is_none(target) { wander() }
  }
}
```
