---
id: huge-mantissa
name: Huge.mantissa
category: huge
kind: namespace-method
tokens: Huge.mantissa
sig: Huge.mantissa(a) -> fixed
tip: The mantissa in [1, 10).
order: 7
ns: Huge
member: mantissa
---

Returns the normalized mantissa, a <code>fixed</code> in [1, 10) (or 0). Pair it with <code>Huge.exp</code> to format a value your own way.

```ludic
program Demo {
  handler Step phase Update {
    let m = Huge.mantissa(gold)
  }
}
```
