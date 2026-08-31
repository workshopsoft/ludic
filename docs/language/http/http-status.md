---
id: http-status
name: Http.status
category: http
kind: namespace-method
tokens: Http.status
sig: Http.status(handle) -> int
tip: The response HTTP status code.
order: 9
ns: Http
member: status
---

Returns the cached HTTP status code (<code>0</code> until the reply lands or on error).

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    if Http.poll(h) > 0 { print(Http.status(h)) }
  }
}
```
