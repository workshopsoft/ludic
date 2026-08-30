---
id: mime-of
name: Mime.of
category: mime
kind: namespace-method
tokens: Mime.of
sig: Mime.of(path) -> string
tip: MIME type from a file extension.
order: 1
ns: Mime
member: of
---

Returns the MIME type inferred from the file extension (e.g. <code>hero.png</code> → <code>image/png</code>), or <code>application/octet-stream</code> for an unknown extension. A pure lookup — it does not open the file.

Parameters:
- `path` — the path or filename

```ludic
program MimeOf {
  entry {
    if Mime.of("hero.png") == "image/png" { print(1) }
  }
}
```
