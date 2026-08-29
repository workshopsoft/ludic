---
id: text-concat
name: Text.concat
category: text
kind: namespace-method
tokens: Text.concat
sig: Text.concat(a, b) -> string
tip: Join two strings into a new one.
order: 8
ns: Text
member: concat
---

Returns a fresh string that is <code>a</code> followed by <code>b</code>. It is the call form of the <code>a + b</code> string operator and allocates a new string, leaving the inputs untouched. For building a line from several pieces, backtick interpolation such as <code>`score: {n}`</code> is usually clearer; reach for <code>Text.concat</code> when joining two values you already hold.

Parameters:
- `a` — the left string
- `b` — the right string

```ludic
program Greeting {
  var name: string = "world"

  handler Build phase Update {
    let line = Text.concat("hello ", name)   # "hello world"
  }
}
```
