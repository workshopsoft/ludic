---
id: http-get
name: Http.get
category: http
kind: namespace-method
tokens: Http.get
sig: Http.get(url) -> int
tip: Start an async GET request.
order: 0
ns: Http
member: get
---

Starts an asynchronous GET and returns a request handle. Poll it each frame with <a href="http-poll.html"><code>Http.poll</code></a>; the frame never blocks.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com/scores")
  }
}
```
