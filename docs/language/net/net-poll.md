---
id: net-poll
name: Net.poll
category: net
kind: namespace-method
tokens: Net.poll
sig: Net.poll(buf, cap) -> int
tip: Read an inbound datagram.
order: 1
ns: Net
member: poll
---

Reads up to <code>cap</code> bytes of the next inbound datagram into <code>buf</code> and returns the byte count, or zero when none is waiting.
