---
id: os-stdout_write
name: Os.stdout_write
category: os
kind: namespace-method
tokens: Os.stdout_write
sig: Os.stdout_write(s)
tip: Write a string to standard output.
order: 12
ns: Os
member: stdout_write
---

Writes a string to standard output verbatim — no trailing newline is added, unlike <code>print</code>. Use it for tool output where you control the exact bytes (progress, generated text, machine-readable lines).

Parameters:
- `s` — the string to write

```ludic
program StdoutWrite {
  entry {
    Os.stdout_write("hello")
    Os.stdout_write("\n")
  }
}
```
