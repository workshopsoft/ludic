---
id: fn-some
name: some
category: builtins
kind: builtin
tokens: some
sig: some(v) -> option
tip: Wrap a present value in an option.
order: 16
---

Wraps a present value in an <code>option</code> — the value type that models <em>maybe a value</em> without a magic <code>-1</code> sentinel. An <code>option</code> is either <code>some(value)</code> (this) or <a href="fn-none"><code>none</code></a> (empty); test it with <a href="fn-is_some"><code>is_some</code></a> / <a href="fn-is_none"><code>is_none</code></a> and read it with <a href="fn-unwrap_or"><code>unwrap_or</code></a>. The payload is any <code>i32</code>-width scalar — <code>int</code>, <code>fixed</code>, <code>bool</code>, or <code>entity</code>.

Parameters:
- `v` — the present value

```ludic
program Targeting {
  function nearest(count: int) -> option {
    if count == 0 { return none() }
    return some(count - 1)          # the nearest target index
  }
  test "some carries the value" {
    let t = unwrap_or(nearest(3), 0 - 1)
    expect_eq(t, 2)
  }
}
```
