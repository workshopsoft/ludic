---
id: fs-size
name: Fs.size
category: fs
kind: namespace-method
tokens: Fs.size
sig: Fs.size(p) -> int
tip: File size in bytes.
order: 7
ns: Fs
member: size
---

Returns the size of a file in bytes, or <code>-1</code> if it cannot be opened. Useful for progress bars or sanity checks before loading.

Parameters:
- `p` — the path

```ludic
program Size {
  entry {
    let n = Fs.size("assets/level1.dat")
    if n >= 0 { print(n) }
  }
}
```
