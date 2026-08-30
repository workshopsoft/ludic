---
id: crypto-sha256
name: Crypto.sha256
category: crypto
kind: namespace-method
tokens: Crypto.sha256
sig: Crypto.sha256(s) -> string
tip: SHA-256 of a string, as 64 hex characters.
order: 1
ns: Crypto
member: sha256
---

Computes the SHA-256 digest of the bytes of <code>s</code> and returns it as a 64-character lowercase hex string. This is the standard, FIPS 180-4 algorithm — the same digest every other conforming implementation produces — so it is deterministic across platforms and runs and is backed by published known-answer vectors. Use it to fingerprint content, or as the building block under <a href="crypto-hmac_sha256"><code>Crypto.hmac_sha256</code></a> for signing. On its own SHA-256 is <em>not</em> a message authentication code: anyone can recompute it, so it proves what the data is, not who produced it.

Parameters:
- `s` — the string whose bytes are hashed

```ludic
program Fingerprint {
  entry {
    let digest = Crypto.sha256("abc")
    print(digest)   # ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
  }
}
```
