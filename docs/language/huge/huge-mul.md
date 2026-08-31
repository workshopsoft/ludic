---
id: huge-mul
name: Huge.mul
category: huge
kind: namespace-method
tokens: Huge.mul
sig: Huge.mul(a, b) -> Huge
tip: Product of two big numbers.
order: 3
ns: Huge
member: mul
---

Multiplies two big numbers (mantissas multiply, exponents add) — the exponential growth step at the heart of an idle game.

```ludic
program Demo {
  handler Step phase Update {
    gold = Huge.mul(gold, multiplier)
  }
}
```
