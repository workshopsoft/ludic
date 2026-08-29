---
id: net-serialize
name: Net.serialize
category: net
kind: namespace-method
tokens: Net.serialize
sig: Net.serialize(entity, buf) -> int
tip: Serialize an entity's synced state.
order: 2
ns: Net
member: serialize
---

Writes the <code>@Sync</code> fields of <code>entity</code> into <code>buf</code> and returns the byte count, for sending over the wire.
