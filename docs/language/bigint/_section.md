---
id: bigint
title: BigInt
order: 10
---

Arbitrary-precision integers with no upper bound, for idle/incremental counters, exact huge currencies, and score arithmetic that a 32- or 64-bit <code>int</code> would overflow. A <code>BigInt</code> is a sign-magnitude number stored as base-1e9 limbs, so every operation is <strong>exact</strong> and therefore deterministic — bit-identical on every platform, with no binary floating point. Build one with <code>BigInt.from</code> (an <code>int</code>) or <code>BigInt.parse</code> (decimal text), combine with <code>add</code> / <code>sub</code> / <code>mul</code> / <code>pow</code> / <code>div</code> / <code>mod</code>, compare with <code>cmp</code> / <code>eq</code> / <code>is_zero</code>, and render with <code>str</code>. Arguments are positional. The runtime is spliced in only when a program mentions <code>BigInt.*</code>.
