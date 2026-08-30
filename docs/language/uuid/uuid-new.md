---
id: uuid-new
name: Uuid.new
category: uuid
kind: namespace-method
tokens: Uuid.new
sig: Uuid.new() -> string
tip: A new random (v4) UUID as a canonical 36-char string.
order: 1
ns: Uuid
member: new
---

Generates a new **v4** (random) UUID and returns it in canonical lowercase text form, e.g. <code>550e8400-e29b-41d4-a716-446655440000</code>. A v4 UUID carries 122 bits of entropy drawn from the OS secure random generator, so two independently-generated IDs colliding is not something you will ever observe in practice — which is exactly what makes it a good identity for a player, a session, a networked entity, or a piece of user-created content that has no central authority to number it.

This is the default UUID constructor; <a href="uuid-v4"><code>Uuid.v4</code></a> is an explicit alias. Because the value is random it is **non-deterministic** — do not mint UUIDs inside the lockstep simulation, or replays and peers will diverge.

```ludic
program NewId {
  entry {
    let id = Uuid.new()
    print(len(id))   # 36
  }
}
```
