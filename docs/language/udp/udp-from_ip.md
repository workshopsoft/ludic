---
id: udp-from_ip
name: Udp.from_ip
category: udp
kind: namespace-method
tokens: Udp.from_ip
sig: Udp.from_ip(socket) -> int
tip: The sender of the last datagram read.
order: 4
ns: Udp
member: from_ip
---

The address the last datagram read on this socket came from - the one to answer.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    print(Udp.from_ip(socket: s))
  }
}
```
