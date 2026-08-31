---
id: huge-neg
name: Huge.neg
category: huge
kind: namespace-method
tokens: Huge.neg
sig: Huge.neg(a) -> Huge
tip: Negate a big number.
order: 4
ns: Huge
member: neg
---

Returns <code>-a</code>, the same magnitude with the opposite sign.

```ludic
program Demo {
  handler Step phase Update {
    let owed = Huge.neg(balance)
  }
}
```
