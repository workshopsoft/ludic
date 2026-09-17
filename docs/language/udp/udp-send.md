---
id: udp-send
name: Udp.send
category: udp
kind: namespace-method
tokens: Udp.send
sig: Udp.send(socket, ip, port, bytes, len) -> int
tip: Send one datagram.
order: 2
ns: Udp
member: send
---

Sends the first <code>len</code> bytes of <code>bytes</code> to <code>ip</code>:<code>port</code> as one datagram and returns the number of bytes sent, or <code>-1</code>.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    let buf = Memory.bytes(4)
    Memory.poke(buf, 0, 1)
    print(Udp.send(socket: s, ip: Udp.ip(text: "127.0.0.1"), port: Udp.port(socket: s), bytes: buf, len: 1))
  }
}
```
