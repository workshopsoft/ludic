---
id: http-body_len
name: Http.body_len
category: http
kind: namespace-method
tokens: Http.body_len
sig: Http.body_len(handle) -> int
tip: The response body length in bytes.
order: 12
ns: Http
member: body_len
---

Returns the length of the response body in bytes.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    if Http.poll(h) > 0 { print(Http.body_len(h)) }
  }
}
```
