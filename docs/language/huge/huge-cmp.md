---
id: huge-cmp
name: Huge.cmp
category: huge
kind: namespace-method
tokens: Huge.cmp
sig: Huge.cmp(a, b) -> int
tip: Compare two big numbers: -1, 0, or 1.
order: 5
ns: Huge
member: cmp
---

Compares two big numbers, returning <code>-1</code>, <code>0</code>, or <code>1</code> as <code>a</code> is less than, equal to, or greater than <code>b</code>.

```ludic
program Demo {
  handler Step phase Update {
    if Huge.cmp(gold, price) >= 0 { buy() }
  }
}
```
