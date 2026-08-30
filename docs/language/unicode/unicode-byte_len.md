---
id: unicode-byte_len
name: Unicode.byte_len
category: unicode
kind: namespace-method
tokens: Unicode.byte_len
sig: Unicode.byte_len(s) -> int
tip: Number of bytes in a string.
order: 2
ns: Unicode
member: byte_len
---

The number of <strong>bytes</strong> the string occupies — its storage size. This is what raw byte APIs and buffers care about, and it is greater than <a href="unicode-len"><code>len</code></a> whenever the text contains non-ASCII code points (each of which encodes to 2–4 bytes).

Parameters:
- `s` — the UTF-8 string

```ludic
program ByteLen {
  entry {
    print(Unicode.byte_len("hello"))   # 5 (all ASCII)
  }
}
```
