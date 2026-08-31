---
id: http-post
name: Http.post
category: http
kind: namespace-method
tokens: Http.post
sig: Http.post(url, body) -> int
tip: Start an async POST with a body.
order: 1
ns: Http
member: post
---

Starts an asynchronous POST with a string body, returning a request handle.

```ludic
program Demo {
  entry {
    let h = Http.post("https://example.com/score", "{\"score\":42}")
  }
}
```
