---
id: udp-open_local
name: Udp.open_local
category: udp
kind: namespace-method
tokens: Udp.open_local
sig: Udp.open_local(port) -> int
tip: Open a socket only this machine can reach.
order: 0
ns: Udp
member: open_local
---

Opens a non-blocking IPv4 socket like <a href="udp-open.html"><code>Udp.open</code></a>, but bound to <code>127.0.0.1</code> alone: programs on the same machine reach it, and nothing on the network can. Use it for a port only local tools should talk to, such as a development link. Returns the handle, or <code>0</code> when it could not.

```ludic
program Demo {
  entry {
    let s = Udp.open_local(port: 0)
    print(s > 0)
  }
}
```
