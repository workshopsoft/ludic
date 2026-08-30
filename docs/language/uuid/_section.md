---
id: uuid
title: Uuid
order: 6
---

Universally-unique identifiers — stable IDs that don't collide, generated locally with no central authority handing out numbers. Reach for a UUID whenever something needs an identity that survives being saved, shared, or sent over a network: players and sessions in multiplayer, user-created content (levels, items, mods) that has to merge cleanly across installs, or a per-install / per-run ID for analytics and bug reports.

Two versions are provided. <a href="uuid-new"><code>Uuid.new</code></a> makes a **v4** (random) UUID — 122 bits of entropy, effectively never colliding. <a href="uuid-new_v7"><code>Uuid.new_v7</code></a> makes a **v7** (time-ordered) UUID whose leading bits are a millisecond timestamp, so a batch of v7 IDs sorts by creation time — friendly to database indexes and append logs. Both set the RFC 4122 version and variant bits correctly.

A UUID is represented as its canonical lowercase 36-character text form (<code>8-4-4-4-12</code>), the same shape you store, print, send, and compare — so there is no conversion at each boundary. Validate untrusted input with <a href="uuid-is_valid"><code>Uuid.is_valid</code></a> or normalise it with <a href="uuid-parse"><code>Uuid.parse</code></a>, and compare with <a href="uuid-equals"><code>Uuid.equals</code></a>, which ignores case.

**Determinism caveat.** v4 and the random tail of v7 come from the OS cryptographically-secure RNG (<a href="ns-Crypto"><code>Crypto</code></a>), which is non-deterministic by design. Minting a UUID inside the lockstep simulation will desync replays and networked peers — generate IDs at the edges (on connect, on save, on spawn-from-input), never per tick in reproducible gameplay code.
