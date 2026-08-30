---
id: fs-copy
name: Fs.copy
category: fs
kind: namespace-method
tokens: Fs.copy
sig: Fs.copy(src, dst) -> bool
tip: Copy a file byte-for-byte.
order: 9
ns: Fs
member: copy
---

Copies a file's bytes to a new path (atomically at the destination), returning <code>true</code> on success. Binary-safe, so it works for assets as well as text. Copying directories is a follow-up.

Parameters:
- `src` — the source path
- `dst` — the destination path

```ludic
program Copy {
  entry {
    if Fs.copy("saves/slot1.json", "saves/slot1.bak") { print(1) }
  }
}
```
