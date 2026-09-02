---
id: pool-reserved
name: Pool.reserved
category: pool
kind: namespace-method
tokens: Pool.reserved
sig: Pool.reserved() -> int
tip: High-water: how many slots have ever been allocated.
order: 3
ns: Pool
member: reserved
---

Returns the high-water mark — how many entity slots have ever been allocated. It only grows when a <code>spawn</code> finds the freelist empty; a spawn that reuses a freed slot leaves it unchanged, so a steady-state spawn/despawn loop keeps <code>reserved</code> flat (the proof that slots are pooled, not reallocated).
