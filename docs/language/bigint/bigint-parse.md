---
id: bigint-parse
name: BigInt.parse
category: bigint
kind: namespace-method
tokens: BigInt.parse
sig: BigInt.parse(text) -> BigInt
tip: Parse decimal text into a BigInt.
order: 1
ns: BigInt
member: parse
---

Parses decimal text (an optional leading sign then digits) into a <code>BigInt</code> — the way to enter a value too large for an <code>int</code> literal.

```ludic
program Demo {
  handler Step phase Update {
    let huge = BigInt.parse("123456789012345678901234567890")
  }
}
```
