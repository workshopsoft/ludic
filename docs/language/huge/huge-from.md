---
id: huge-from
name: Huge.from
category: huge
kind: namespace-method
tokens: Huge.from
sig: Huge.from(value) -> Huge
tip: Turn an int into a Huge.
order: 0
ns: Huge
member: from
---

Lifts a plain <code>int</code> into a <code>Huge</code>, the starting point for idle-game magnitudes that grow past the integer range.

```ludic
program Demo {
  handler Step phase Update {
    var gold = Huge.from(1000)
  }
}
```
