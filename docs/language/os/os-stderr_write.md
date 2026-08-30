---
id: os-stderr_write
name: Os.stderr_write
category: os
kind: namespace-method
tokens: Os.stderr_write
sig: Os.stderr_write(s)
tip: Write a string to standard error.
order: 13
ns: Os
member: stderr_write
---

Writes a string to standard error verbatim. Standard error is the right stream for diagnostics, warnings, and usage messages: it stays separate from a tool's real output on standard out, so a caller can capture one without the other.

Parameters:
- `s` — the string to write

```ludic
program StderrWrite {
  entry {
    Os.stderr_write("warning: using defaults\n")
    print(0)
  }
}
```
