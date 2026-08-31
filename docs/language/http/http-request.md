---
id: http-request
name: Http.request
category: http
kind: namespace-method
tokens: Http.request
sig: Http.request(method, url, body) -> int
tip: Start a request with any method.
order: 2
ns: Http
member: request
---

Starts a request with an explicit method ("GET", "PUT", "DELETE", …) and optional body.

```ludic
program Demo {
  entry {
    let h = Http.request("PUT", "https://example.com/item/1", "payload")
  }
}
```
