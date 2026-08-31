---
id: fn-err
name: err
category: builtins
kind: builtin
tokens: err
sig: err(msg: string) -> result
tip: Wrap a failure message in a result — the sad half, recovered by try/else.
order: 13
---

Wraps a failure in a <code>result</code>, carrying a message that says what went wrong. It is the counterpart to <a href="fn-ok"><code>ok</code></a>: a fallible function (declared <code>-&gt; result</code>) returns <code>err("…")</code> on the sad path instead of crashing or returning a magic sentinel. The caller recovers with <a href="kw-try"><code>try</code></a>/<code>else</code> — the <code>else</code> block sees the message as <code>error</code> — or tests it with <a href="fn-is_err"><code>is_err</code></a>. Unlike <a href="fn-panic"><code>panic</code></a>, which aborts, <code>err</code> is a value: the program keeps running and chooses a fallback.

Parameters:
- `msg` — a message describing the failure (a string)

```ludic
program Config {
  function volume(pct: int) -> result {
    if pct < 0 or pct > 100 { return err("volume out of range") }
    return ok(pct)
  }
  test "err drives the fallback" {
    let v = try volume(150) else { 100 }    # clamp to a safe default
    expect_eq(v, 100)
  }
}
```
