---
id: fs-mkdir
name: Fs.mkdir
category: fs
kind: namespace-method
tokens: Fs.mkdir
sig: Fs.mkdir(p) -> bool
tip: Create a directory and its parents.
order: 8
ns: Fs
member: mkdir
---

Creates a directory, including any missing parent directories (like <code>mkdir -p</code>). Returns <code>true</code> if the directory exists afterwards, so calling it on an existing directory is fine.

Parameters:
- `p` — the directory path to create

```ludic
program Mkdir {
  entry {
    if Fs.mkdir("saves/campaign") { print(1) }
  }
}
```
