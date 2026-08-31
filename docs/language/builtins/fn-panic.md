---
id: fn-panic
name: panic
category: builtins
kind: builtin
tokens: panic
sig: panic(msg: string)
tip: Abort with a located error message instead of crashing.
order: 10
---

Prints <code>file:line: panic: &lt;msg&gt;</code> to standard error and aborts the process with exit code 1. It turns "something went wrong" into a clear, located message a non-expert can act on — the opposite of a raw segfault or a silent wrong result. Use it for the unrecoverable case: a corrupt asset, a broken invariant, a branch that should be impossible. The source location is baked in at compile time, so the message always points at the exact call. For a guarded check that only aborts when a condition fails, use <a href="fn-assert"><code>assert</code></a>.

Recoverable failures — a missing save, a bad network packet — are a different story: those should be values a game can fall back from rather than a `panic`. That value-carrying path is <a href="kw-try"><code>try</code></a>/<code>else</code> over a <a href="fn-ok"><code>result</code></a>; `panic` covers the unrecoverable programmer-bug half.

Parameters:
- `msg` — a message describing what went wrong (a string)

```ludic
program Demo {
  function pick(options: int, n: int) -> int {
    if n < 0 { panic("choice index is negative") }
    if n >= options { panic("choice index out of range") }
    return n
  }
  entry {
    print(pick(3, 1))     # 1
    print(pick(3, 9))     # aborts: Demo.ludic:6: panic: choice index out of range
  }
}
```
