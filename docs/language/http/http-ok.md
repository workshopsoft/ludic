---
id: http-ok
name: Http.ok
category: http
kind: namespace-method
tokens: Http.ok
sig: Http.ok(handle) -> bool
tip: Was the response status 2xx?
order: 10
ns: Http
member: ok
---

Returns whether the response status is in the 2xx success range.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    if Http.poll(h) > 0 { if Http.ok(h) { print(1) } }
  }
}
```
