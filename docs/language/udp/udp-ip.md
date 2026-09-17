---
id: udp-ip
name: Udp.ip
category: udp
kind: namespace-method
tokens: Udp.ip
sig: Udp.ip(text) -> int
tip: Parse a dotted address.
order: 9
ns: Udp
member: ip
---

Turns <code>"a.b.c.d"</code> into an address, or <code>0</code> when the text is not one.

```ludic
program Demo {
  entry {
    print(Udp.ip(text: "10.0.0.2"))
  }
}
```
