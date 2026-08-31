---
id: kw-try
name: try
category: control
kind: keyword
tokens: try
sig: try EXPR else { … }
tip: Recover a fallible result as a value, with a fallback — no exceptions, no unwinding.
order: 12
---

A <code>try EXPR else { … }</code> expression recovers a fallible operation without exceptions or unwinding. <code>EXPR</code> evaluates to a <a href="fn-ok"><code>result</code></a> — a value carrying either a success payload (from <a href="fn-ok"><code>ok</code></a>) or a failure message (from <a href="fn-err"><code>err</code></a>). When it is <code>ok</code>, the whole <code>try</code> expression <em>is</em> that payload and the <code>else</code> block is skipped. When it is <code>err</code>, the <code>else</code> block runs and its trailing expression supplies the fallback value; inside the block the failure message is bound to <code>error</code>, so you can log or branch on it. It is a plain branch on the result's tag — the happy path stays one line, there is no hidden control flow, and nothing unwinds the stack.

The payload is an <code>i32</code>-width scalar (<code>int</code>, <code>fixed</code>, <code>bool</code>, or <code>entity</code>) — the common case of "a number or nothing". For richer payloads and full pattern-matching over tagged unions, see the type-system work (#1).

```ludic
program SaveLoad {
  # a fallible op returns a result: ok(payload) or err(message)
  function load_score(slot: int) -> result {
    if slot == 1 { return ok(4200) }
    return err("no save in that slot")
  }

  test "ok yields the payload, err falls back" {
    let a = try load_score(1) else { 0 }      # 4200
    let b = try load_score(9) else { 0 }      # 0 (fallback)
    expect_eq(a, 4200)
    expect_eq(b, 0)
  }

  test "the fallback can read the failure via `error`" {
    var logged = 0
    let score = try load_score(3) else {
      if error == "no save in that slot" { logged = 1 }
      0                                        # trailing expression = the fallback
    }
    expect_eq(score, 0)
    expect_eq(logged, 1)
  }
}
```
