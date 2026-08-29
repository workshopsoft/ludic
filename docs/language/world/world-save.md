---
id: world-save
name: World.save
category: world
kind: namespace-method
tokens: World.save
sig: World.save(buf) -> int
tip: Serialize the world into a buffer.
order: 6
ns: World
member: save
---

Writes a binary snapshot of the whole ECS world into <code>buf</code> and returns the number of bytes written. Size the buffer with <code>World.size</code>.
