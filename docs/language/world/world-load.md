---
id: world-load
name: World.load
category: world
kind: namespace-method
tokens: World.load
sig: World.load(buf, len) -> void
tip: Restore the world from a buffer.
order: 7
ns: World
member: load
---

Replaces the current world with the snapshot in the first <code>len</code> bytes of <code>buf</code> — the inverse of <code>World.save</code>.
