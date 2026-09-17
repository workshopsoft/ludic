---
id: http-expected
name: Http.expected
category: http
kind: namespace-method
tokens: Http.expected
sig: Http.expected(handle) -> int
tip: The body length the server announced, or -1.
order: 18
ns: Http
member: expected
---

Returns the length of the response body as the server announced it (<code>Content-Length</code>), or <code>-1</code> while that is not known. For a request given <a href="http-save_to.html"><code>Http.save_to</code></a> it is known as soon as the headers arrive, and stays <code>-1</code> for a reply sent without a length (chunked) — draw an indeterminate bar then. For an ordinary in-memory request it is <code>-1</code> until the reply lands, then the body length.

```ludic
program Demo {
  entry {
    let h = Http.open("GET", "https://example.com/big.bin")
    Http.save_to(h, "big.bin.part")
    Http.send(h)
    print(Http.expected(h))   # -1: nothing has arrived yet
  }
}
```
