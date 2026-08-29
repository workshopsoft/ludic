---
id: net-apply
name: Net.apply
category: net
kind: namespace-method
tokens: Net.apply
sig: Net.apply(entity, buf) -> int
tip: Apply serialized state to an entity.
order: 3
ns: Net
member: apply
---

Reads synced fields from <code>buf</code> into <code>entity</code> — the inverse of <code>Net.serialize</code>.
