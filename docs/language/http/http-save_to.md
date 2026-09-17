---
id: http-save_to
name: Http.save_to
category: http
kind: namespace-method
tokens: Http.save_to
sig: Http.save_to(handle, path) -> void
tip: Stream the response body to a file.
order: 16
ns: Http
member: save_to
---

Makes the response body of an <a href="http-open.html"><code>Http.open</code></a>ed request go straight to the file at <code>path</code> as it arrives, instead of into memory — the way to download something large (an update package of hundreds of megabytes) with a progress bar. Call it before <a href="http-send.html"><code>Http.send</code></a>; afterwards it does nothing.

The file is written directly at <code>path</code>, with no temporary name: <code>Http.send</code> creates it (or truncates an existing one), and a failed or cancelled download leaves whatever had arrived. So download to a name of your own such as <code>"x.nupkg.part"</code> and rename it once <a href="http-poll.html"><code>Http.poll</code></a> reports a good status — a non-2xx reply's body (an error page) is written to the file too. If the file cannot be created the request finishes with status <code>0</code>, as does one whose write fails midway (a full disk).

For such a request <a href="http-text.html"><code>Http.text</code></a> is empty (<code>null</code>) and <a href="http-body_len.html"><code>Http.body_len</code></a> is the number of bytes written. Follow progress with <a href="http-received.html"><code>Http.received</code></a> and <a href="http-expected.html"><code>Http.expected</code></a>. Freeing the request while it is pending cancels the download. The transfer asks for no compression (<code>Accept-Encoding: identity</code>) unless the request set that header, so the bytes counted are the bytes on disk. Files are limited to 2 GB.

```ludic
program Demo {
  entry {
    let h = Http.open("GET", "https://example.com/big.bin")
    Http.save_to(h, "big.bin.part")
    Http.send(h)
  }
}
```
