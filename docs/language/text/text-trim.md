---
id: text-trim
name: Text.trim
category: text
kind: namespace-method
tokens: Text.trim
sig: Text.trim(s) -> string
tip: A copy with surrounding whitespace removed.
order: 13
ns: Text
member: trim
---

Returns a fresh string with leading and trailing whitespace (spaces, tabs, newlines, carriage returns) removed; inner spacing is kept. Use it to clean up typed input or a parsed field before comparing or storing it.

```ludic
program Demo {
  handler Step phase Update {
    let name = Text.trim(raw_input)
  }
}
```
