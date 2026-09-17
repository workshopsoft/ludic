---
id: udp-port
name: Udp.port
category: udp
kind: namespace-method
tokens: Udp.port
sig: Udp.port(socket) -> int
tip: The port a socket is bound to.
order: 1
ns: Udp
member: port
---

Returns the port the socket is bound to - the one the system chose when it was opened on port <code>0</code>.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    print(Udp.port(socket: s) > 0)
  }
}
```
