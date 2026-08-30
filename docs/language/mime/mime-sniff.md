---
id: mime-sniff
name: Mime.sniff
category: mime
kind: namespace-method
tokens: Mime.sniff
sig: Mime.sniff(path) -> string
tip: MIME type refined by magic bytes.
order: 2
ns: Mime
member: sniff
---

Reads the file's leading bytes and recognises well-known signatures (PNG, JPEG, GIF, PDF), so a mislabelled or extension-less file is still identified. Falls back to <a href="mime-of"><code>Mime.of</code></a> when no signature matches or the file cannot be read.

Parameters:
- `path` — the path to inspect

```ludic
program MimeSniff {
  entry {
    let kind = Mime.sniff("download.bin")
    print(len(kind))
  }
}
```
