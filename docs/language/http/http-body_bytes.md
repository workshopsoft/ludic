---
id: http-body_bytes
name: Http.body_bytes
category: http
kind: namespace-method
tokens: Http.body_bytes
sig: Http.body_bytes(handle, bytes, len) -> void
tip: Set a raw byte request body.
order: 6
ns: Http
member: body_bytes
---

Sets a raw request body of <code>len</code> bytes (for binary uploads).

```ludic
program Demo {
  entry {
    let buf = bytes(4)
    let h = Http.open("POST", "https://example.com/upload")
    Http.body_bytes(h, buf, 4)
    Http.send(h)
  }
}
```
