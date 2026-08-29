---
id: fn-exit
name: exit
category: builtins
kind: builtin
tokens: exit
sig: exit(code)
tip: Terminate the process immediately with a status code.
order: 21
---

Terminates the process at once with the given status code, without waiting for the current frame to finish. This is a harder stop than <code>quit</code>, which ends the game loop cleanly after the frame completes; use <code>exit</code> for command-line tools and tests that need to signal success or failure to the shell, where <code>0</code> conventionally means success and any non-zero value means an error. Because it stops immediately, drawing queued for the current frame is not presented.

Parameters:
- `code` — the process exit status (`0` for success, non-zero for failure)

```ludic
program RequireArgument {
  handler CheckArgs phase Start {
    if arg_count() < 2 {
      print(0)
      exit(1)
    }
    print(1)
    exit(0)
  }
}
```
