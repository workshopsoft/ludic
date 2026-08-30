---
id: path-stem
name: Path.stem
category: path
kind: namespace-method
tokens: Path.stem
sig: Path.stem(p) -> string
tip: The final component without its extension.
order: 5
ns: Path
member: stem
---

Returns the final component with its extension removed — the "stem". Useful for deriving an id or a sibling filename. <code>stem("mods/foo/data.json")</code> is <code>"data"</code>.

Parameters:
- `p` — the path

```ludic
program Stem {
  entry {
    if Path.stem("data.json") == "data" { print(1) }
  }
}
```
