---
id: udp-from_port
name: Udp.from_port
category: udp
kind: namespace-method
tokens: Udp.from_port
sig: Udp.from_port(socket) -> int
tip: The sender's port.
order: 5
ns: Udp
member: from_port
---

The port the last datagram read on this socket came from.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    print(Udp.from_port(socket: s))
  }
}
```
