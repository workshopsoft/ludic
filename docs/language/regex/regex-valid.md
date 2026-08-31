---
id: regex-valid
name: Regex.valid
category: regex
kind: namespace-method
tokens: Regex.valid
sig: Regex.valid(pattern) -> bool
tip: True if the pattern is well-formed (compiles without error).
order: 2
ns: Regex
member: valid
---

A convenience over <a href="regex-compile"><code>Regex.compile</code></a>: <code>true</code> when <code>pattern</code> compiles, <code>false</code> when it is malformed. Use it to validate a user- or mod-supplied pattern before relying on it.

Parameters:
- `pattern` — the regular expression source

```ludic
program Demo {
  entry {
    if Regex.valid("(a|b)+") { print(1) }
    if not Regex.valid("(unterminated") { print(2) }
  }
}
```
