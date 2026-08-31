---
id: bigint-str
name: BigInt.str
category: bigint
kind: namespace-method
tokens: BigInt.str
sig: BigInt.str(a) -> string
tip: Render a big integer as decimal text.
order: 13
ns: BigInt
member: str
---

Renders the full value as decimal text, with a leading <code>-</code> when negative. This is how you display or serialize a <code>BigInt</code>.

```ludic
program Demo {
  handler Step phase Update {
    Screen.draw_text(8, 8, BigInt.str(score), Color.White, 1)
  }
}
```
