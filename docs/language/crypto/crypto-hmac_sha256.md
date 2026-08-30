---
id: crypto-hmac_sha256
name: Crypto.hmac_sha256
category: crypto
kind: namespace-method
tokens: Crypto.hmac_sha256
sig: Crypto.hmac_sha256(key, msg) -> string
tip: Sign a message with a shared secret key.
order: 2
ns: Crypto
member: hmac_sha256
---

Computes HMAC-SHA256 over <code>msg</code> under the secret <code>key</code> (RFC 2104) and returns the 64-character lowercase hex tag. Unlike a bare hash, a MAC cannot be recomputed without the key, so it authenticates the message: attach the tag to a save file or a network packet, and a receiver who shares the key can tell whether the payload was altered or forged. To check the tag on the other side, pass it to <a href="crypto-verify_hmac"><code>Crypto.verify_hmac</code></a> rather than comparing hex with <code>==</code>.

Parameters:
- `key` — the shared secret; keep it out of the shipped client where you can
- `msg` — the payload being signed

```ludic
program SignSave {
  entry {
    let key = "s3cret"
    let payload = "score=9001;level=12"
    let mac = Crypto.hmac_sha256(key, payload)
    print(mac)
  }
}
```
