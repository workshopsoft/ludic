---
id: kw-test
name: test
category: testing
kind: keyword
tokens: test
sig: test "name" { … }
tip: A named test block, run automatically with pass/fail reporting.
order: 1
---

A <code>test "name" { … }</code> block declares a named test. Every test in a file is discovered automatically and run by a generated entry point — there is no <code>entry</code> to write and nothing to register. The runner prints <code>ok   - name</code> for a test whose assertions all held and <code>FAIL - name</code> for one that had a failure, then a <code>== N passed, M failed ==</code> summary, and the program exits non-zero if any test failed. Writing a test should feel like writing a function: put a few assertions in a block and run it.

Assertions (each records a failure and prints <code>file:line: … failed</code> but keeps going, so one run reports every failure):

- `expect(cond)` — the boolean `cond` must be true.
- `expect_eq(a, b)` — `a` must equal `b`; on failure prints `(got a, want b)`.
- `expect_near(a, b, tol)` — `a` must be within `tol` of `b` (absolute). Use it for `fixed`-point results and accumulated integer math, where an exact match is too brittle.

Run a spec file directly with the compiler-runner — `ludic mymath_test.ludic` compiles it to a native binary, runs it, and forwards the pass/fail exit code — so it drops straight into `bin/x` and CI.

```ludic
program MathSpec {
  function add(a: int, b: int) -> int { return a + b }

  test "addition adds" {
    expect_eq(add(2, 3), 5)
    expect(add(1, 1) == 2)
  }

  test "fixed math is close enough" {
    let half = fixed(1) / 2          # 0.5 in Q16.16
    expect_near(half, 32768, 2)      # within 2 raw units of 0.5
  }
}
```
