---
id: network-poll
name: Network.poll
category: network
kind: namespace-method
tokens: Network.poll
sig: Network.poll(buf, cap) -> int
tip: Read an inbound datagram.
order: 1
ns: Network
member: poll
---

Reads up to <code>cap</code> bytes of the next inbound datagram into <code>buf</code> and returns the byte count, or zero when none is waiting.
