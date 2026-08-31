---
id: huge-add
name: Huge.add
category: huge
kind: namespace-method
tokens: Huge.add
sig: Huge.add(a, b) -> Huge
tip: Sum of two big numbers.
order: 1
ns: Huge
member: add
---

Adds two big numbers, aligning their exponents; a term too small to matter at display precision is dropped.

```ludic
program Demo {
  handler Step phase Update {
    gold = Huge.add(gold, income)
  }
}
```
