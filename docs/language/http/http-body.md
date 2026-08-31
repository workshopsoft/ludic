---
id: http-body
name: Http.body
category: http
kind: namespace-method
tokens: Http.body
sig: Http.body(handle, body) -> void
tip: Set a string request body.
order: 5
ns: Http
member: body
---

Sets a NUL-terminated string request body on an opened request.

```ludic
program Demo {
  entry {
    let h = Http.open("POST", "https://example.com/api")
    Http.body(h, "{\"hi\":1}")
    Http.send(h)
  }
}
```
