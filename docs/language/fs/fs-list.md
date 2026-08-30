---
id: fs-list
name: Fs.list
category: fs
kind: namespace-method
tokens: Fs.list
sig: Fs.list(dir) -> []string
tip: Directory entries, sorted.
order: 10
ns: Fs
member: list
---

Returns the names of the entries in a directory (excluding <code>.</code> and <code>..</code>), sorted ascending for a stable, reproducible order — important for deterministic mod loading. Names are relative; combine with <a href="path-join"><code>Path.join</code></a> for full paths.

Parameters:
- `dir` — the directory to list

```ludic
program List {
  entry {
    let names = Fs.list("mods")
    var i = 0
    while i < len(names) { print(len(names[i])); i = i + 1 }
  }
}
```
