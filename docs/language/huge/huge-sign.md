---
id: huge-sign
name: Huge.sign
category: huge
kind: namespace-method
tokens: Huge.sign
sig: Huge.sign(a) -> int
tip: The sign: -1, 0, or 1.
order: 6
ns: Huge
member: sign
---

Returns the sign of the value: <code>-1</code>, <code>0</code>, or <code>1</code>.

```ludic
program Demo {
  handler Step phase Update {
    if Huge.sign(balance) < 0 { warn() }
  }
}
```
