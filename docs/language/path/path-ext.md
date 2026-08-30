---
id: path-ext
name: Path.ext
category: path
kind: namespace-method
tokens: Path.ext
sig: Path.ext(p) -> string
tip: The file extension, including the dot.
order: 4
ns: Path
member: ext
---

Returns the extension of the final component, including the leading dot (e.g. <code>".json"</code>), or the empty string when there is none. A leading-dot name (a dotfile like <code>.gitignore</code>) has no extension.

Parameters:
- `p` — the path

```ludic
program Ext {
  entry {
    if Path.ext("hero.png") == ".png" { print(1) }
  }
}
```
