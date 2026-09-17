---
id: udp-local_ip
name: Udp.local_ip
category: udp
kind: namespace-method
tokens: Udp.local_ip
sig: Udp.local_ip() -> int
tip: This machine's address.
order: 8
ns: Udp
member: local_ip
---

The address this machine reaches the internet from - the one a player on the same network would dial. No packet is sent; <code>0</code> when there is no route.

```ludic
program Demo {
  entry {
    print(Udp.ip_text(ip: Udp.local_ip()))
  }
}
```
