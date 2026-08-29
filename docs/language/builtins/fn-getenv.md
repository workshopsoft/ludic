---
id: fn-getenv
name: getenv
category: builtins
kind: builtin
tokens: getenv
sig: getenv(name) -> str
tip: Read an environment variable, returning empty when it is unset.
order: 23
---

Returns the value of the named environment variable, or an empty string when that variable is not set. Use it to make command-line tools and headless runs configurable without recompiling — reading a data directory, a log level, or a seed from the environment. Check for the empty string to detect an unset variable and fall back to a default. Like the other system builtins, it is aimed at tooling rather than a shipped game loop.

Parameters:
- `name` — the environment variable name to read

```ludic
program ReadConfig {
  handler ShowConfig phase Start {
    let level = getenv("LUDIC_LEVEL")
    if len(level) == 0 {
      print("default")
    } else {
      print(level)
    }
  }
}
```
