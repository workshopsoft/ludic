---
id: fs-is_dir
name: Fs.is_dir
category: fs
kind: namespace-method
tokens: Fs.is_dir
sig: Fs.is_dir(p) -> bool
tip: Is a path a directory?
order: 2
ns: Fs
member: is_dir
---

Returns whether the path exists and is a directory (as opposed to a file). Useful when walking a tree or deciding whether to recurse.

Parameters:
- `p` — the path to test

```ludic
program IsDir {
  entry {
    if Fs.is_dir("mods") { print(1) } else { print(0) }
  }
}
```
