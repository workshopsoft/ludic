---
id: fn-net_poll
name: net_poll
category: networking
kind: builtin
tokens: net_poll
sig: net_poll(buf, cap) -> int
tip: Receive queued bytes from the transport; returns the byte count.
order: 1
---

Copy up to <code>cap</code> waiting bytes into <code>buf</code> and return how many arrived (0 when nothing is queued). Pair it with the generated <code>apply</code> to fold an update back into the world.
