---
id: pool-free
name: Pool.free
category: pool
kind: namespace-method
tokens: Pool.free
sig: Pool.free() -> int
tip: How many freed slots are waiting to be reused.
order: 2
ns: Pool
member: free
---

Returns how many freed entity slots are on the freelist, waiting to be reused by the next <code>spawn</code>. This is the pool depth — despawning bullets/enemies raises it, and the next wave draws them back down with no allocation.
