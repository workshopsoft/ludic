---
id: path-normalize
name: Path.normalize
category: path
kind: namespace-method
tokens: Path.normalize
sig: Path.normalize(p) -> string
tip: Collapse . / .. / duplicate separators.
order: 6
ns: Path
member: normalize
---

Canonicalizes a path lexically (without touching disk): duplicate separators collapse, <code>.</code> segments drop, and <code>..</code> pops the preceding segment. An absolute path never rises above its root. The result is stable, so it is a good key for comparing or sandboxing paths.

Parameters:
- `p` — the path

```ludic
program Normalize {
  entry {
    if Path.normalize("a/./b/../c") == "a/c" { print(1) }
  }
}
```
