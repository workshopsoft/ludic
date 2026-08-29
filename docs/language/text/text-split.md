---
id: text-split
name: Text.split
category: text
kind: namespace-method
tokens: Text.split
sig: Text.split(s, sep) -> []string
tip: Split a string on a separator into a list.
order: 17
ns: Text
member: split
---

Splits <code>s</code> at every occurrence of the non-empty separator <code>sep</code> and returns the pieces as a <code>[]string</code> — the inverse of <code>Text.join</code>. Adjacent separators yield empty pieces, and a string with no separator returns a one-element list holding the whole string. Use it to parse CSV rows, command arguments, or delimited save data.

```ludic
program Demo {
  handler Step phase Update {
    let fields = Text.split(line, ",")
  }
}
```
