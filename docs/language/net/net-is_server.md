---
id: net-is_server
name: Net.is_server
category: net
kind: namespace-method
tokens: Net.is_server
sig: Net.is_server() -> bool
tip: Is this peer the server?
order: 6
ns: Net
member: is_server
---

Returns true on the authoritative peer. Offline it is true, so server-only guards run in single-player.
