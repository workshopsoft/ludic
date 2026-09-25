---
id: http-received
name: Http.received
category: http
kind: namespace-method
tokens: Http.received
sig: Http.received(handle) -> int
tip: Body bytes received so far.
order: 17
ns: Http
member: received
---

Returns how many bytes of the response body have arrived. For a request given <a href="http-save_to.html"><code>Http.save_to</code></a> it is updated live while the request is pending — the bytes already written to the file — which is what a progress bar reads. For an ordinary in-memory request it is <code>0</code> until the reply lands, then the body length. <code>0</code> before <code>Http.send</code>.

```ludic
program Demo {
  let dl: int = 0
  handler Bar phase Render {
    let got = Http.received(handle: dl)
    let all = Http.expected(handle: dl)
    if all > 0 { Screen.bar(x: 8, y: 8, width: 200, height: 6, value: got / 1024, max: all / 1024, color: 0x55cc77, back: 0x222222) }
  }
}
```
