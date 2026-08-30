---
id: os-env
name: Os.env
category: os
kind: namespace-method
tokens: Os.env
sig: Os.env(name) -> string
tip: Read an environment variable (null if unset).
order: 4
ns: Os
member: env
---

Reads an environment variable and returns its value, or <code>null</code> when the variable is not set. Use <a href="os-env_or"><code>env_or</code></a> when you want a fallback, or <a href="os-has_env"><code>has_env</code></a> to test presence without risking a null.

Parameters:
- `name` — the variable name

```ludic
program Env {
  entry {
    if Os.has_env("HOME") {
      let home = Os.env("HOME")
      print(len(home))
    }
  }
}
```
