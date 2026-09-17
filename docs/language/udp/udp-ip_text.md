---
id: udp-ip_text
name: Udp.ip_text
category: udp
kind: namespace-method
tokens: Udp.ip_text
sig: Udp.ip_text(ip) -> string
tip: Format an address.
order: 10
ns: Udp
member: ip_text
---

Turns an address back into <code>"a.b.c.d"</code>.

```ludic
program Demo {
  entry {
    print(Udp.ip_text(ip: Udp.ip(text: "192.168.1.11")))
  }
}
```
