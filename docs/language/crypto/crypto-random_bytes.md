---
id: crypto-random_bytes
name: Crypto.random_bytes
category: crypto
kind: namespace-method
tokens: Crypto.random_bytes
sig: Crypto.random_bytes(n) -> string
tip: n bytes from the OS CSPRNG, as a 2n-character hex string.
order: 6
ns: Crypto
member: random_bytes
---

Draws <code>n</code> bytes from the operating system's cryptographically-secure random number generator and returns them as a <code>2n</code>-character lowercase hex string. Use it for unguessable tokens, nonces, and session secrets — anything whose whole value is that an attacker cannot predict it. The result is hex rather than raw bytes for the same reason digests are: a <code>str</code> is null-terminated and raw random bytes can contain a zero byte, so hex is the form you can safely store and compare.

This is deliberately **non-deterministic** — it must never seed the lockstep simulation RNG (<a href="ns-Random"><code>Random</code></a>). Two calls return different values. On a platform without an OS CSPRNG (for example a bare wasm target) the draw degrades to zeroes rather than faulting; treat a real CSPRNG there as a platform-layer responsibility.

Parameters:
- `n` — the number of secure random bytes to draw

```ludic
program Token {
  entry {
    let session = Crypto.random_bytes(16)   # 32 hex chars, unguessable
    print(len(session))                      # 32
  }
}
```
