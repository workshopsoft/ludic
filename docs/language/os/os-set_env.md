---
id: os-set_env
name: Os.set_env
category: os
kind: namespace-method
tokens: Os.set_env
sig: Os.set_env(name, value) -> bool
tip: Set an environment variable.
order: 7
ns: Os
member: set_env
---

Sets an environment variable for this process (and any children it launches), overwriting any existing value. Returns <code>true</code> on success. Environment changes are process-local and non-deterministic host state — keep them out of the simulation.

Parameters:
- `name` — the variable name
- `value` — the value to set

```ludic
program SetEnv {
  entry {
    if Os.set_env("LUDIC_MODE", "fast") { print(1) }
  }
}
```
