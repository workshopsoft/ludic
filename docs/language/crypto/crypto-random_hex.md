---
id: crypto-random_hex
name: Crypto.random_hex
category: crypto
kind: namespace-method
tokens: Crypto.random_hex
sig: Crypto.random_hex(n) -> string
tip: Alias for random_bytes — n secure bytes as a 2n-char hex string.
order: 7
ns: Crypto
member: random_hex
---

Identical to <a href="crypto-random_bytes"><code>Crypto.random_bytes</code></a>: draws <code>n</code> bytes from the OS CSPRNG and returns them as a <code>2n</code>-character lowercase hex string. The two names are interchangeable; <code>random_hex</code> exists so call sites can be explicit that the return value is already hex text (not raw bytes) when that reads more clearly. The same determinism caveat applies — the result is unpredictable by design and must stay out of the reproducible simulation RNG.

Parameters:
- `n` — the number of secure random bytes to draw

```ludic
program Nonce {
  entry {
    let nonce = Crypto.random_hex(12)   # 24 hex chars
    print(len(nonce))                    # 24
  }
}
```
