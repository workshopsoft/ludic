---
id: http-parse
name: Http.parse
category: http
kind: namespace-method
tokens: Http.parse
sig: Http.parse(bytes, len) -> int
tip: Parse a raw HTTP response into a handle.
order: 15
ns: Http
member: parse
---

Parses a raw HTTP/1.1 response (status line + headers + body) into a ready handle — useful for caches, custom transports, and tests. Transport-independent and pure.

```ludic
program Demo {
  entry {
    let raw = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nhi"
    let h = Http.parse(raw, Text.length(raw))
    print(Http.status(h))
  }
}
```
