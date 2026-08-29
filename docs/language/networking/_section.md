---
id: networking
title: Networking
order: 9
---

Multiplayer is a compile-time property of the ECS, not glue you thread by hand. Mark fields <code>@Sync</code> and models <code>@Owned</code>; the compiler generates the replication. These are the low-level primitives beneath that sugar, for when you drive the transport yourself.
