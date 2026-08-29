---
id: text-repeat
name: Text.repeat
category: text
kind: namespace-method
tokens: Text.repeat
sig: Text.repeat(s, n) -> string
tip: A string repeated n times.
order: 14
ns: Text
member: repeat
---

Returns <code>s</code> concatenated with itself <code>n</code> times; <code>n &lt;= 0</code> yields the empty string. Handy for drawing a text bar, an indent, or a separator line without a loop.

```ludic
program Demo {
  handler Step phase Update {
    let bar = Text.repeat("#", filled)
  }
}
```
