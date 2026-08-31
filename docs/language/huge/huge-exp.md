---
id: huge-exp
name: Huge.exp
category: huge
kind: namespace-method
tokens: Huge.exp
sig: Huge.exp(a) -> int
tip: The base-10 exponent.
order: 8
ns: Huge
member: exp
---

Returns the base-10 exponent — how many orders of magnitude the value spans.

```ludic
program Demo {
  handler Step phase Update {
    let order = Huge.exp(gold)
  }
}
```
