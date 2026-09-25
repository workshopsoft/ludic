---
id: fn-print
name: print
category: builtins
kind: builtin
tokens: print
sig: print(x)
tip: Print an int or string followed by a newline — for headless tests and debugging.
order: 0
---

Writes its argument to standard output followed by a newline. It accepts either an integer or a string, so it is the go-to tool for quick debugging and for headless test programs that emit numbers a test harness can check. It is a diagnostic channel, separate from anything drawn on screen with the <code>Screen</code> API, and is most useful in <code>Start</code>- or <code>Update</code>-phase handlers while you are iterating. For interpolated messages, build the string first with a backtick template and pass that.

Parameters:
- `x` — the value to print, an `int` or a string

```ludic
program PrintScore {
  state PrintScoreState {
    score: int = 0
  }

  handler CountUp(print_score_st: mut PrintScoreState) phase Update {
    print_score_st.score = print_score_st.score + 10
    print(print_score_st.score)
    if print_score_st.score >= 30 { quit() }
  }
}
```
