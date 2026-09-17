---
id: udp-recv
name: Udp.recv
category: udp
kind: namespace-method
tokens: Udp.recv
sig: Udp.recv(socket, bytes, cap) -> int
tip: Read the next waiting datagram.
order: 3
ns: Udp
member: recv
---

Copies the next waiting datagram, up to <code>cap</code> bytes, into <code>bytes</code> and returns its length, or <code>0</code> when nothing is waiting. It never blocks: call it in a loop each frame until it returns <code>0</code>. The sender is <a href="udp-from_ip.html"><code>Udp.from_ip</code></a> / <a href="udp-from_port.html"><code>from_port</code></a>.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    let buf = Memory.bytes(64)
    print(Udp.recv(socket: s, bytes: buf, cap: 64))
  }
}
```
