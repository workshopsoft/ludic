---
id: net-send
name: Net.send
category: net
kind: namespace-method
tokens: Net.send
sig: Net.send(peer, buf, len) -> void
tip: Put a datagram on the wire.
order: 0
ns: Net
member: send
---

Sends the first <code>len</code> bytes of <code>buf</code> to <code>peer</code>. Absent a real socket it uses the built-in loopback, so offline code still runs.
