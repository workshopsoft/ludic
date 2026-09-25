---
id: text-contains
name: Text.contains
category: text
kind: namespace-method
tokens: Text.contains
sig: Text.contains(s, sub) -> bool
tip: Whether a substring appears anywhere in a string.
order: 5
ns: Text
member: contains
---

Returns <code>true</code> when <code>sub</code> occurs anywhere inside <code>s</code>. An empty substring is always considered present. Use it for a quick membership test — filtering a log line, checking for a forbidden word, or seeing whether a path includes a folder — when you do not need the position. Reach for <code>Text.index_of</code> when you also want where it matched.

Parameters:
- `s` — the string to search
- `sub` — the substring to look for

```ludic
program Filter {
  let line: string = "error: disk full"

  handler Scan phase Update {
    if Text.contains(line, "error") {
      # flag it
    }
  }
}
```
