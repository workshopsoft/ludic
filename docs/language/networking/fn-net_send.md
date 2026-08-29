---
id: fn-net_send
name: net_send
category: networking
kind: builtin
tokens: net_send
sig: net_send(peer, buf, len)
tip: Send bytes to a peer over the host's transport.
order: 0
---

Send <code>len</code> bytes from <code>buf</code> to <code>peer</code>. The transport itself is a host-provided seam — UDP natively, WebRTC/WebSocket on the web, or a loopback in tests — so the same game runs over any of them.
