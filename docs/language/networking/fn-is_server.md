---
id: fn-is_server
name: is_server / is_owner / local_id
category: networking
kind: builtin
tokens: is_server is_owner local_id
sig: is_server() -> bool   is_owner(e) -> bool   local_id() -> int
tip: Role and identity checks the runtime sets.
order: 3
---

The runtime sets the local role. <code>is_server()</code> is the authority check, <code>is_owner(e)</code> is true when this peer owns <code>e</code>, and <code>local_id()</code> is this peer's id. Prefer role annotations to sprinkling these through gameplay code.
