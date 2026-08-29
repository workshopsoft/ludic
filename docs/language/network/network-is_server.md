---
id: network-is_server
name: Network.is_server
category: network
kind: namespace-method
tokens: Network.is_server
sig: Network.is_server() -> bool
tip: Is this peer the server?
order: 6
ns: Network
member: is_server
---

Returns true on the authoritative peer. Offline it is true, so server-only guards run in single-player.
