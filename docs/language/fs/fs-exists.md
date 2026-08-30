---
id: fs-exists
name: Fs.exists
category: fs
kind: namespace-method
tokens: Fs.exists
sig: Fs.exists(p) -> bool
tip: Does a path exist?
order: 1
ns: Fs
member: exists
---

Returns whether anything (file or directory) exists at the path. A cheap existence check before reading or writing.

Parameters:
- `p` — the path to test

```ludic
program Exists {
  entry {
    if Fs.exists("settings.ini") { print(1) } else { print(0) }
  }
}
```
