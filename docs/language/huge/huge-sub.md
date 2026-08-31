---
id: huge-sub
name: Huge.sub
category: huge
kind: namespace-method
tokens: Huge.sub
sig: Huge.sub(a, b) -> Huge
tip: Difference of two big numbers.
order: 2
ns: Huge
member: sub
---

Subtracts <code>b</code> from <code>a</code>.

```ludic
program Demo {
  handler Step phase Update {
    gold = Huge.sub(gold, cost)
  }
}
```
