---
id: text-replace
name: Text.replace
category: text
kind: namespace-method
tokens: Text.replace
sig: Text.replace(s, from, to) -> string
tip: Replace every occurrence of a substring.
order: 19
ns: Text
member: replace
---

Returns a fresh string with every occurrence of <code>from</code> in <code>s</code> replaced by <code>to</code>; if <code>from</code> never appears the string is returned unchanged. Use it to substitute tokens in a template, swap a delimiter, or sanitize input.

```ludic
program Demo {
  handler Step phase Update {
    let path = Text.replace(name, " ", "_")
  }
}
```
