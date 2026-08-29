---
id: network-serialize
name: Network.serialize
category: network
kind: namespace-method
tokens: Network.serialize
sig: Network.serialize(entity, buf) -> int
tip: Serialize an entity's synced state.
order: 2
ns: Network
member: serialize
---

Writes the <code>@Sync</code> fields of <code>entity</code> into <code>buf</code> and returns the byte count, for sending over the wire.
