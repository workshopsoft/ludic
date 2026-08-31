---
id: fn-assert
name: assert
category: builtins
kind: builtin
tokens: assert
sig: assert(cond: bool, msg: string)
tip: Abort with a located message when an invariant is false.
order: 11
---

When <code>cond</code> is false, prints <code>file:line: assertion failed: &lt;msg&gt;</code> to standard error and aborts (exit code 1); when it is true, execution continues. It is the guarded form of <a href="fn-panic"><code>panic</code></a> — for the programmer-bug cases the language should catch loudly rather than let corrupt the world: an index that must be in range, a value that must be non-negative, a state that must hold before a step. The location is baked in at compile time, so a failure points at the exact assertion. Assertions document and enforce the invariants a system relies on; keep them for "this must be true" checks, not for recoverable runtime conditions.

Parameters:
- `cond` — the invariant that must hold (a bool)
- `msg` — a message describing the invariant (a string)

```ludic
program Demo {
  function withdraw(balance: int, amount: int) -> int {
    assert(amount >= 0, "amount must be non-negative")
    assert(amount <= balance, "cannot overdraw")
    return balance - amount
  }
  entry {
    print(withdraw(100, 30))   # 70
    print(withdraw(100, 250))  # aborts: Demo.ludic:4: assertion failed: cannot overdraw
  }
}
```
