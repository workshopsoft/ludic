---
id: fs-remove
name: Fs.remove
category: fs
kind: namespace-method
tokens: Fs.remove
sig: Fs.remove(p) -> bool
tip: Delete a file.
order: 6
ns: Fs
member: remove
---

Deletes a file, returning <code>true</code> on success. Use it to clear a save slot or a temporary export.

Parameters:
- `p` — the path to delete

```ludic
program Remove {
  entry {
    if Fs.remove("saves/slot1.json") { print(1) } else { print(0) }
  }
}
```
