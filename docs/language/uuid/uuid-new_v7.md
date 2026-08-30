---
id: uuid-new_v7
name: Uuid.new_v7
category: uuid
kind: namespace-method
tokens: Uuid.new_v7
sig: Uuid.new_v7() -> string
tip: A new time-ordered (v7) UUID; sorts by creation time.
order: 3
ns: Uuid
member: new_v7
---

Generates a new **v7** (time-ordered) UUID. Its leading 48 bits are a Unix-millisecond timestamp, so a batch of v7 IDs sorts lexicographically by creation time — which keeps database indexes and append-only logs tidy in a way random v4 IDs do not. The remaining bits are secure random, so IDs minted in the same millisecond are still distinct, and the RFC 4122 version (7) and variant bits are set.

Sub-second resolution is derived from the wall clock in seconds (multiplied to milliseconds), so ordering is guaranteed at one-second granularity with the random tail breaking ties within a second. Like v4 this reads the non-deterministic wall clock and CSPRNG — generate at the edges, never inside reproducible simulation. <a href="uuid-v7"><code>Uuid.v7</code></a> is an alias.

```ludic
program NewV7 {
  entry {
    let id = Uuid.new_v7()
    print(id[14..15])   # 7 — the version nibble
  }
}
```
