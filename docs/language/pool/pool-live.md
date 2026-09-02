---
id: pool-live
name: Pool.live
category: pool
kind: namespace-method
tokens: Pool.live
sig: Pool.live() -> int
tip: How many entities are currently alive.
order: 1
ns: Pool
member: live
---

Returns the number of entities currently alive (reserved minus free). Despawning drops it and spawning raises it; a recycled slot does not change <a href="pool-reserved"><code>Pool.reserved</code></a>.
