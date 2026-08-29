---
id: text-join
name: Text.join
category: text
kind: namespace-method
tokens: Text.join
sig: Text.join(parts, sep) -> string
tip: Join a list of strings with a separator.
order: 18
ns: Text
member: join
---

Concatenates the strings in the slice <code>parts</code> into one string, placing <code>sep</code> between each — the inverse of <code>Text.split</code>. With an empty separator it simply concatenates. Use it to build a CSV row, a path, or a display list from pieces.

```ludic
program Demo {
  handler Step phase Update {
    let line = Text.join(fields, ",")
  }
}
```
