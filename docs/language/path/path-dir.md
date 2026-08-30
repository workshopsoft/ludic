---
id: path-dir
name: Path.dir
category: path
kind: namespace-method
tokens: Path.dir
sig: Path.dir(p) -> string
tip: The directory part of a path.
order: 2
ns: Path
member: dir
---

Returns everything before the last <code>/</code> — the containing directory. A path with no separator yields <code>"."</code> (the current directory); the root <code>/</code> stays <code>/</code>.

Parameters:
- `p` — the path

```ludic
program Dir {
  entry {
    if Path.dir("mods/foo/data.json") == "mods/foo" { print(1) }
  }
}
```
