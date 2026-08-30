---
id: path-base
name: Path.base
category: path
kind: namespace-method
tokens: Path.base
sig: Path.base(p) -> string
tip: The final component of a path.
order: 3
ns: Path
member: base
---

Returns the final component — the file or last directory name — after the last <code>/</code>. A path with no separator is returned unchanged. The complement of <a href="path-dir"><code>dir</code></a>.

Parameters:
- `p` — the path

```ludic
program Base {
  entry {
    if Path.base("mods/foo/data.json") == "data.json" { print(1) }
  }
}
```
