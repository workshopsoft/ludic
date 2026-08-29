---
id: network-is_owner
name: Network.is_owner
category: network
kind: namespace-method
tokens: Network.is_owner
sig: Network.is_owner(entity) -> bool
tip: Does this peer own the entity?
order: 7
ns: Network
member: is_owner
---

Returns true when this peer owns <code>entity</code> — <code>owner(entity) == local_id()</code>.
