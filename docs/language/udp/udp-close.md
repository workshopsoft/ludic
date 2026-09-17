---
id: udp-close
name: Udp.close
category: udp
kind: namespace-method
tokens: Udp.close
sig: Udp.close(socket) -> void
tip: Close a socket.
order: 6
ns: Udp
member: close
---

Closes the socket and frees its handle.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    Udp.close(socket: s)
  }
}
```
