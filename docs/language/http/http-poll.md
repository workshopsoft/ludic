---
id: http-poll
name: Http.poll
category: http
kind: namespace-method
tokens: Http.poll
sig: Http.poll(handle) -> int
tip: Poll a request; -1 pending, 0 error, else status.
order: 8
ns: Http
member: poll
---

Polls a request without blocking: returns <code>-1</code> while pending, <code>0</code> on a transport error, else the HTTP status code once the reply lands.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    let st = Http.poll(h)
    if st > 0 { print(Http.status(h)) }
  }
}
```
