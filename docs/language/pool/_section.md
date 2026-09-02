---
id: pool
title: Pool
order: 35
---

Entity-pool statistics. Ludic's ECS is already pool-based: the allocator recycles freed entity slots through a freelist (a <a href="../structure/kw-model"><code>despawn</code></a>ed slot is reused by the next <code>spawn</code> before any new slot is taken), and component storage is fixed per-entity arrays — so spawning and despawning many entities per frame does no per-spawn heap allocation and cannot fragment. <a href="pool-live"><code>Pool.live</code></a> / <a href="pool-free"><code>Pool.free</code></a> / <a href="pool-reserved"><code>Pool.reserved</code></a> / <a href="pool-capacity"><code>Pool.capacity</code></a> read those counters so a bullet-hell or horde game can watch reuse and budget against the cap.
