---
id: http-send
name: Http.send
category: http
kind: namespace-method
tokens: Http.send
sig: Http.send(handle) -> void
tip: Dispatch an opened request.
order: 7
ns: Http
member: send
---

Dispatches an opened request onto the background worker. After this the request is in flight; poll it.

```ludic
program Demo {
  entry {
    let h = Http.open("GET", "https://example.com")
    Http.send(h)
  }
}
```
