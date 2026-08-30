---
id: uuid-v4
name: Uuid.v4
category: uuid
kind: namespace-method
tokens: Uuid.v4
sig: Uuid.v4() -> string
tip: Explicit alias for Uuid.new — a random (v4) UUID.
order: 2
ns: Uuid
member: v4
---

An explicit alias for <a href="uuid-new"><code>Uuid.new</code></a>: generates a **v4** (random) UUID in canonical lowercase text form. Use this spelling when the surrounding code also uses <a href="uuid-v7"><code>Uuid.v7</code></a> and naming both by version reads more clearly than <code>new</code> versus <code>new_v7</code>. The behaviour, entropy, and non-determinism caveat are identical to <code>Uuid.new</code>.

```ludic
program V4 {
  entry {
    let a = Uuid.v4()
    let b = Uuid.v4()
    if a != b { print(1) }   # two draws differ
  }
}
```
