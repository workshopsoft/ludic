---
id: network-apply
name: Network.apply
category: network
kind: namespace-method
tokens: Network.apply
sig: Network.apply(entity, buf) -> int
tip: Apply serialized state to an entity.
order: 3
ns: Network
member: apply
---

Reads synced fields from <code>buf</code> into <code>entity</code> — the inverse of <code>Network.serialize</code>.
