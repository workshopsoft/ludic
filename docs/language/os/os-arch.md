---
id: os-arch
name: Os.arch
category: os
kind: namespace-method
tokens: Os.arch
sig: Os.arch() -> string
tip: The host CPU architecture.
order: 11
ns: Os
member: arch
---

The host CPU architecture as reported by the system, e.g. <code>"arm64"</code> or <code>"x86_64"</code>. This reads the <code>uname</code> machine field using the macOS/BSD layout; a target-aware value for other platforms is a documented follow-up.

```ludic
program Arch {
  entry {
    let a = Os.arch()
    print(len(a))
  }
}
```
