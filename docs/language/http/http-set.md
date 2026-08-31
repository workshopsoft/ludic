---
id: http-set
name: Http.set
category: http
kind: namespace-method
tokens: Http.set
sig: Http.set(handle, name, value) -> void
tip: Set a request header before sending.
order: 4
ns: Http
member: set
---

Sets a request header on an opened request (before <a href="http-send.html"><code>Http.send</code></a>).

```ludic
program Demo {
  entry {
    let h = Http.open("GET", "https://example.com")
    Http.set(h, "Accept", "application/json")
    Http.send(h)
  }
}
```
