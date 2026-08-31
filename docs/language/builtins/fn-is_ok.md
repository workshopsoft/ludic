---
id: fn-is_ok
name: is_ok
category: builtins
kind: builtin
tokens: is_ok
sig: is_ok(r: result) -> bool
tip: True when a result carries a success payload.
order: 14
---

Tests a <code>result</code>'s tag: <code>true</code> when it was built with <a href="fn-ok"><code>ok</code></a>, <code>false</code> when it was built with <a href="fn-err"><code>err</code></a>. Use it when you want to branch on success without unwrapping the payload — the payload itself is recovered with <a href="kw-try"><code>try</code></a>/<code>else</code>. It is the exact negation of <a href="fn-is_err"><code>is_err</code></a>.

Parameters:
- `r` — the result to test

```ludic
program Check {
  function find(x: int) -> result {
    if x == 7 { return ok(x) }
    return err("missing")
  }
  test "is_ok classifies without unwrapping" {
    expect(is_ok(find(7)))
    expect(not is_ok(find(3)))
  }
}
```
