---
id: crypto-random_u32
name: Crypto.random_u32
category: crypto
kind: namespace-method
tokens: Crypto.random_u32
sig: Crypto.random_u32() -> int
tip: One CSPRNG-drawn 32-bit integer.
order: 8
ns: Crypto
member: random_u32
---

Draws four bytes from the OS CSPRNG and assembles them into one 32-bit integer. Use it when you need a single unpredictable number rather than a hex string — a random challenge value, a per-run identifier, or a non-deterministic seed to hand to a *fresh* <a href="ns-Random"><code>Random</code></a> stream at startup. Because the bytes come from the secure generator, the value prints as a signed integer and can be negative.

Like the other secure-random helpers this is **non-deterministic** and must not be called inside the lockstep simulation: doing so desyncs replays and networked peers. Draw it at the edges (startup, on connect) and, if you need reproducible gameplay randomness afterward, seed <a href="random-seed"><code>Random.seed</code></a> with it once.

```ludic
program Challenge {
  entry {
    let c = Crypto.random_u32()
    Random.seed(value: c)          # non-deterministic seed, chosen once at startup
    print(Random.int(100))
  }
}
```
