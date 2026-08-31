---
id: fn-none
name: none
category: builtins
kind: builtin
tokens: none
sig: none() -> option
tip: The empty option — a missing value.
order: 17
---

The empty <code>option</code> — a missing value with no sentinel. Return it when there is nothing to give: no target, an empty slot, a lookup that missed. The caller distinguishes it from <a href="fn-some"><code>some</code></a> with <a href="fn-is_none"><code>is_none</code></a> / <a href="fn-is_some"><code>is_some</code></a>, or supplies a default with <a href="fn-unwrap_or"><code>unwrap_or</code></a>.

```ludic
program Slots {
  function held(slot: int) -> option {
    if slot < 0 { return none() }
    return some(slot)
  }
  test "none is empty" {
    expect_eq(is_none(held(0 - 1)), true)
  }
}
```
