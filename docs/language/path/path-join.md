---
id: path-join
name: Path.join
category: path
kind: namespace-method
tokens: Path.join
sig: Path.join(a, b) -> string
tip: Join two path segments with the separator.
order: 1
ns: Path
member: join
---

Joins two path segments with a single <code>/</code>, inserting one only when needed (so <code>join("a/", "b")</code> and <code>join("a", "b")</code> both give <code>a/b</code>). If <code>b</code> is absolute it wins; if either side is empty the other is returned.

Parameters:
- `a` — the leading path
- `b` — the trailing path or filename

```ludic
program Join {
  entry {
    if Path.join("mods", "foo.ludic") == "mods/foo.ludic" { print(1) }
  }
}
```
