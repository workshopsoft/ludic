---
id: udp-open
name: Udp.open
category: udp
kind: namespace-method
tokens: Udp.open
sig: Udp.open(port) -> int
tip: Open a socket on a port.
order: 0
ns: Udp
member: open
---

Opens a non-blocking IPv4 socket bound to <code>port</code> on every interface and returns its handle, or <code>0</code> when it could not. Port <code>0</code> lets the system pick a free one; <a href="udp-port.html"><code>Udp.port</code></a> says which.

```ludic
program Demo {
  entry {
    let s = Udp.open(port: 0)
    print(s > 0)
  }
}
```
