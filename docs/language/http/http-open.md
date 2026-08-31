---
id: http-open
name: Http.open
category: http
kind: namespace-method
tokens: Http.open
sig: Http.open(method, url) -> int
tip: Open a request to configure before sending.
order: 3
ns: Http
member: open
---

Opens a request without sending it, so headers and a body can be added first with <a href="http-set.html"><code>Http.set</code></a> / <a href="http-body.html"><code>Http.body</code></a>, then dispatched with <a href="http-send.html"><code>Http.send</code></a>.

```ludic
program Demo {
  entry {
    let h = Http.open("POST", "https://example.com/api")
    Http.set(h, "Authorization", "Bearer token")
    Http.body(h, "{}")
    Http.send(h)
  }
}
```
