---
id: fn-ok
name: ok
category: builtins
kind: builtin
tokens: ok
sig: ok(v) -> result
tip: Wrap a success payload in a result — the happy half of try/else.
order: 12
---

Wraps a success value in a <code>result</code> — the value type a fallible function returns. A <code>result</code> carries either a success payload (this) or a failure message (from <a href="fn-err"><code>err</code></a>), and a caller recovers it with <a href="kw-try"><code>try</code></a>/<code>else</code> or classifies it with <a href="fn-is_ok"><code>is_ok</code></a> / <a href="fn-is_err"><code>is_err</code></a>. A function that can fail declares <code>-&gt; result</code> and returns <code>ok(value)</code> on the happy path.

The payload is any <code>i32</code>-width scalar — <code>int</code>, <code>fixed</code>, <code>bool</code>, or <code>entity</code>.

Parameters:
- `v` — the success payload

```ludic
program Parse {
  function to_digit(c: int) -> result {
    if c >= 48 and c <= 57 { return ok(c - 48) }   # '0'..'9'
    return err("not a digit")
  }
  test "ok carries the parsed value" {
    let d = try to_digit(55) else { 0 }            # '7' -> 7
    expect_eq(d, 7)
  }
}
```
