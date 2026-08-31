---
id: regex-replace
name: Regex.replace
category: regex
kind: namespace-method
tokens: Regex.replace
sig: Regex.replace(text, pattern, replacement) -> string
tip: Replace every match; the replacement expands \0..\9 group references.
order: 8
ns: Regex
member: replace
---

Returns a new string with every non-overlapping match of <code>pattern</code> in <code>text</code> replaced by <code>replacement</code>. In the replacement, <code>\0</code> is the whole match, <code>\1</code>…<code>\9</code> are capture groups, and <code>\\</code> is a literal backslash — the natural fit for dialogue/localization token substitution.

Parameters:
- `text` — the string to transform
- `pattern` — the regular expression source
- `replacement` — the replacement, with `\0`..`\9` group references

```ludic
program Demo {
  entry {
    print(Regex.replace("hi {name}!", "\\{(\\w+)\\}", "[\\1]"))
  }
}
```
