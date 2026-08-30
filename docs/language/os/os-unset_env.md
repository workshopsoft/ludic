---
id: os-unset_env
name: Os.unset_env
category: os
kind: namespace-method
tokens: Os.unset_env
sig: Os.unset_env(name) -> bool
tip: Remove an environment variable.
order: 8
ns: Os
member: unset_env
---

Removes an environment variable from this process. Returns <code>true</code> on success (including when the variable was already absent).

Parameters:
- `name` — the variable name

```ludic
program UnsetEnv {
  entry {
    Os.set_env("LUDIC_TMP", "1")
    if Os.unset_env("LUDIC_TMP") { print(1) }
  }
}
```
