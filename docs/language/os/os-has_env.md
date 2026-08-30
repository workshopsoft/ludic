---
id: os-has_env
name: Os.has_env
category: os
kind: namespace-method
tokens: Os.has_env
sig: Os.has_env(name) -> bool
tip: Is an environment variable set?
order: 6
ns: Os
member: has_env
---

Tests whether an environment variable is set, without reading its value. Useful as a feature/debug toggle, or to guard an <a href="os-env"><code>env</code></a> read.

Parameters:
- `name` — the variable name

```ludic
program HasEnv {
  entry {
    if Os.has_env("LUDIC_DEBUG") { print(1) } else { print(0) }
  }
}
```
