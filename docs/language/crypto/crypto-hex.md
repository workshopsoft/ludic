---
id: crypto-hex
name: Crypto.hex
category: crypto
kind: namespace-method
tokens: Crypto.hex
sig: Crypto.hex(s) -> string
tip: Lowercase hex of a string's bytes.
order: 4
ns: Crypto
member: hex
---

Encodes the bytes of <code>s</code> as a lowercase hex string — two characters per byte, so an <em>n</em>-byte input becomes a <em>2n</em>-character result. It is the same encoding <a href="crypto-sha256"><code>Crypto.sha256</code></a> already applies to a digest, exposed on its own so you can render arbitrary bytes (a key id, a small binary token) in a form that is safe to print, log, or embed in text.

Parameters:
- `s` — the string whose bytes are encoded

```ludic
program HexDump {
  entry {
    print(Crypto.hex("abc"))   # 616263
  }
}
```
