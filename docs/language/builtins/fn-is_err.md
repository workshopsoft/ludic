---
id: fn-is_err
name: is_err
category: builtins
kind: builtin
tokens: is_err
sig: is_err(r: result) -> bool
tip: True when a result carries a failure.
order: 15
---

Tests a <code>result</code>'s tag: <code>true</code> when it was built with <a href="fn-err"><code>err</code></a>, <code>false</code> when it was built with <a href="fn-ok"><code>ok</code></a>. Use it to detect the failure case explicitly — for example to count or log failures — while <a href="kw-try"><code>try</code></a>/<code>else</code> handles recovering a value. It is the exact negation of <a href="fn-is_ok"><code>is_ok</code></a>.

Parameters:
- `r` — the result to test

```ludic
program Retry {
  function step(n: int) -> result {
    if n < 3 { return err("not ready") }
    return ok(n)
  }
  test "is_err detects the failure case" {
    expect(is_err(step(1)))
    expect(not is_err(step(5)))
  }
}
```
