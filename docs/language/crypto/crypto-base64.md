---
id: crypto-base64
name: Crypto.base64
category: crypto
kind: namespace-method
tokens: Crypto.base64
sig: Crypto.base64(s) -> string
tip: Standard base64 (RFC 4648) of a string's bytes.
order: 9
ns: Crypto
member: base64
---

Encodes the bytes of <code>s</code> as standard base64 (RFC 4648, the <code>A–Z a–z 0–9 + /</code> alphabet with <code>=</code> padding). Base64 turns arbitrary bytes into printable ASCII, which is what you want when a digest, key, or binary blob has to travel through a text-only channel — a JSON field, a URL-safe token wrapper, a config file, a log line. It is an *encoding*, not encryption: it hides nothing and adds no integrity. Pair it with <a href="crypto-hmac_sha256"><code>Crypto.hmac_sha256</code></a> when the payload must also be tamper-evident.

The output length is always a multiple of four; a one- or two-byte remainder in the input is padded with <code>=</code>.

Parameters:
- `s` — the string whose bytes are encoded

```ludic
program Encode {
  entry {
    print(Crypto.base64("foobar"))   # Zm9vYmFy
    print(Crypto.base64("f"))        # Zg==
  }
}
```
