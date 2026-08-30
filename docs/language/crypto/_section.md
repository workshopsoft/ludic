---
id: crypto
title: Crypto
order: 6
---

Secure, test-vector-backed hashing for the handful of security-sensitive things a game actually does: signing a save or leaderboard payload so casual tampering is detectable, and verifying that a network message or token was not forged by someone who does not hold the key. This is the deliberate counterpart to the fast <a href="ns-Hash"><code>Hash</code></a> library — same idea, opposite trade-off. <code>Hash</code> is fast and reversible and must never guard anything; <code>Crypto</code> is <a href="crypto-sha256"><code>SHA-256</code></a> and <a href="crypto-hmac_sha256"><code>HMAC-SHA256</code></a> implemented to the standard, so the algorithms are the ones with published known-answer tests rather than anything home-grown.

Digests are returned as lowercase hex strings, not raw bytes — a <code>str</code> is null-terminated and a raw digest can contain a zero byte, so hex is the form you can print, store, and compare directly.

What this is not: it is not DRM and it is not unbeatable anti-cheat. A client-side game cannot keep a secret from the machine it runs on — a determined owner can always read the key out of the binary. Use it to make *casual* tampering detectable and to authenticate messages between parties who share a key. To verify a MAC always use <a href="crypto-verify_hmac"><code>Crypto.verify_hmac</code></a> (a constant-time check), never <code>==</code>, which leaks how much of a guessed MAC was correct.
