---
id: crypto-verify_hmac
name: Crypto.verify_hmac
category: crypto
kind: namespace-method
tokens: Crypto.verify_hmac
sig: Crypto.verify_hmac(key, msg, mac) -> bool
tip: Constant-time check that a MAC matches.
order: 3
ns: Crypto
member: verify_hmac
---

Recomputes HMAC-SHA256(<code>key</code>, <code>msg</code>) and compares it to the supplied <code>mac</code> hex string, returning <code>true</code> only if they match. The comparison is <em>constant-time</em>: it never stops early on the first differing character, so it does not leak — through how long the check took — how many leading bytes of a forged tag happened to be right. That leak is exactly what lets an attacker guess a MAC one byte at a time, which is why you should always verify with this and never with <code>==</code>. A mismatched length returns <code>false</code> immediately (the length of a MAC is not a secret).

Parameters:
- `key` — the shared secret used to sign
- `msg` — the payload as received
- `mac` — the hex tag to check, e.g. from <a href="crypto-hmac_sha256"><code>Crypto.hmac_sha256</code></a>

```ludic
program CheckSave {
  entry {
    let key = "s3cret"
    let payload = "score=9001;level=12"
    let mac = Crypto.hmac_sha256(key, payload)
    if Crypto.verify_hmac(key, payload, mac) {
      print(1)   # untampered
    } else {
      print(0)   # altered or forged
    }
  }
}
```
