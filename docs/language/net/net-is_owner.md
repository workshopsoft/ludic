---
id: net-is_owner
name: Net.is_owner
category: net
kind: namespace-method
tokens: Net.is_owner
sig: Net.is_owner(entity) -> bool
tip: Does this peer own the entity?
order: 7
ns: Net
member: is_owner
---

Returns true when this peer owns <code>entity</code> — <code>owner(entity) == local_id()</code>.
