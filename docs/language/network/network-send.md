---
id: network-send
name: Network.send
category: network
kind: namespace-method
tokens: Network.send
sig: Network.send(peer, buf, len) -> void
tip: Put a datagram on the wire.
order: 0
ns: Network
member: send
---

Sends the first <code>len</code> bytes of <code>buf</code> to <code>peer</code>. Absent a real socket it uses the built-in loopback, so offline code still runs.
