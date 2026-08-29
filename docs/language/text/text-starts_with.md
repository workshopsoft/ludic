---
id: text-starts_with
name: Text.starts_with
category: text
kind: namespace-method
tokens: Text.starts_with
sig: Text.starts_with(s, prefix) -> bool
tip: Whether a string begins with a given prefix.
order: 3
ns: Text
member: starts_with
---

Returns <code>true</code> when <code>s</code> begins with <code>prefix</code>, comparing byte for byte over the length of the prefix. An empty prefix always matches. Use it to route commands (<code>"/help ..."</code>), recognize a tag, or branch on a filename extension without slicing first.

Parameters:
- `s` — the string to test
- `prefix` — the leading substring to look for

```ludic
program Command {
  var input: string = "/say hello"

  handler Parse phase Update {
    if Text.starts_with(input, "/say ") {
      let msg = Text.slice(input, 5, Text.length(input))
    }
  }
}
```
