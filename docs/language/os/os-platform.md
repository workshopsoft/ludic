---
id: os-platform
name: Os.platform
category: os
kind: namespace-method
tokens: Os.platform
sig: Os.platform() -> string
tip: The host platform id.
order: 10
ns: Os
member: platform
---

The host platform as a short id: <code>"macos"</code>, <code>"linux"</code>, or the raw <code>uname</code> system name on other Unixes. Derived from the operating-system name, which is portable across every Unix host. Non-deterministic host input — read it to branch on platform, not inside the simulation.

```ludic
program Platform {
  entry {
    if Os.platform() == "macos" { print(1) } else { print(0) }
  }
}
```
