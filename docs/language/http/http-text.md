---
id: http-text
name: Http.text
category: http
kind: namespace-method
tokens: Http.text
sig: Http.text(handle) -> str
tip: The response body as text.
order: 11
ns: Http
member: text
---

Returns the response body as a NUL-terminated string. Pair with <code>Json.parse</code> (#44) for JSON APIs.

```ludic
program Demo {
  entry {
    let h = Http.get("https://example.com")
    if Http.poll(h) > 0 { print(Http.text(h)) }
  }
}
```
