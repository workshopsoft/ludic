---
id: regex-exec
name: Regex.exec
category: regex
kind: namespace-method
tokens: Regex.exec
sig: Regex.exec(text, re) -> Match
tip: Like find, but with an already-compiled Regex.
order: 6
ns: Regex
member: exec
---

The compiled-pattern form of <a href="regex-find"><code>Regex.find</code></a>: returns the first <code>Match</code> of the pre-compiled <code>re</code> in <code>text</code>, or <code>null</code>.

Parameters:
- `text` — the string to search
- `re` — a compiled `Regex`

```ludic
program Demo {
  entry {
    let re = Regex.compile("#(\\w+)")
    let m = Regex.exec("a #tag b", re)
    print(Regex.group(m, 1))
  }
}
```
