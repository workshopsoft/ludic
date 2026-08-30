---
id: os-env_or
name: Os.env_or
category: os
kind: namespace-method
tokens: Os.env_or
sig: Os.env_or(name, fallback) -> string
tip: Read an environment variable, or a fallback.
order: 5
ns: Os
member: env_or
---

Reads an environment variable, returning <code>fallback</code> when it is not set — the null-safe way to read optional configuration. The result is always non-null, so it is safe to use directly.

Parameters:
- `name` — the variable name
- `fallback` — the value to use when the variable is unset

```ludic
program EnvOr {
  entry {
    let assets = Os.env_or("LUDIC_ASSETS", "assets/")
    print(len(assets))
  }
}
```
