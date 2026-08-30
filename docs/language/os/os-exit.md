---
id: os-exit
name: Os.exit
category: os
kind: namespace-method
tokens: Os.exit
sig: Os.exit(code)
tip: Terminate the process with a status code.
order: 9
ns: Os
member: exit
---

Terminates the process immediately with the given status code — <code>0</code> for success, non-zero for failure, the convention every shell and CI system reads. Nothing after the call runs. Intended for tools and launchers; a game normally ends through its own lifecycle instead.

Parameters:
- `code` — the process exit status (0 = success)

```ludic
program Exit {
  entry {
    if Os.arg_count() < 2 {
      Os.stderr_write("usage: tool <arg>\n")
      Os.exit(1)
    }
    print(0)
  }
}
```
