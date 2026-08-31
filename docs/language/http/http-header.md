---
id: http-header
name: Http.header
category: http
kind: namespace-method
tokens: Http.header
sig: Http.header(handle, name) -> str
tip: A response header value (case-insensitive).
order: 13
ns: Http
member: header
---

Returns a response header value by name (case-insensitive), or an empty result if absent.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    if Http.poll(h) > 0 { print(Http.header(h, "Content-Type")) }
  }
}
```
