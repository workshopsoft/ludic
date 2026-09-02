---
id: pool-capacity
name: Pool.capacity
category: pool
kind: namespace-method
tokens: Pool.capacity
sig: Pool.capacity() -> int
tip: The maximum number of entities.
order: 4
ns: Pool
member: capacity
---

Returns the maximum number of live entities (the fixed entity-array size). Budget spawns against it — a horde/bullet-hell game keeps <a href="pool-live"><code>Pool.live</code></a> under <code>Pool.capacity()</code>.
