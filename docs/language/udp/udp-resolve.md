---
id: udp-resolve
name: Udp.resolve
category: udp
kind: namespace-method
tokens: Udp.resolve
sig: Udp.resolve(name) -> int
tip: Look a host name up.
order: 7
ns: Udp
member: resolve
---

Returns the first IPv4 address of a host name, or <code>0</code>. It waits for the system's resolver, so call it outside the frame loop.

```ludic
program Demo {
  entry {
    print(Udp.ip_text(ip: Udp.resolve(name: "localhost")))
  }
}
```
