---
id: network
title: Network
order: 6
---

The low-level networking seam — send and poll datagrams, serialize and apply entity state, and read ownership and role. Multiplayer is normally a compile-time property of the ECS, not glue you thread by hand: mark fields <code>@Sync</code> and models <code>@Owned</code> and the compiler generates the replication. These <code>Network.*</code> primitives are what that sugar lowers to, for when you drive the transport yourself. Offline they collapse to single-player defaults.
