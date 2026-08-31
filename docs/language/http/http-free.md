---
id: http-free
name: Http.free
category: http
kind: namespace-method
tokens: Http.free
sig: Http.free(handle) -> void
tip: Release a request's resources.
order: 14
ns: Http
member: free
---

Releases a request handle and the resources it owns (the body copy and any retained response). Free each request once you are done reading it.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    if Http.poll(h) > 0 { Http.free(h) }
  }
}
```
