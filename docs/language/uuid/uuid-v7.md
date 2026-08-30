---
id: uuid-v7
name: Uuid.v7
category: uuid
kind: namespace-method
tokens: Uuid.v7
sig: Uuid.v7() -> string
tip: Explicit alias for Uuid.new_v7 — a time-ordered UUID.
order: 4
ns: Uuid
member: v7
---

An explicit alias for <a href="uuid-new_v7"><code>Uuid.new_v7</code></a>: generates a **v7** (time-ordered) UUID whose leading bits are a millisecond timestamp so the IDs sort by creation time. Use this spelling to sit symmetrically beside <a href="uuid-v4"><code>Uuid.v4</code></a>. Behaviour, timestamp resolution, and the determinism caveat are identical to <code>Uuid.new_v7</code>.

```ludic
program V7 {
  entry {
    let id = Uuid.v7()
    if Uuid.is_valid(id) { print(1) }
  }
}
```
