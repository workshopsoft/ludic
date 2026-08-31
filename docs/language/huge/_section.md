---
id: huge
title: Huge
order: 14
---

Idle/incremental big numbers — magnitudes far past what a 32- or 64-bit integer can hold, for prestige currencies and exponential growth. A <code>Huge</code> is a normalized mantissa (a Q16.16 <code>fixed</code> in [1, 10)) times <code>10^exponent</code>, so it can represent 10^100 or 10^1000 while staying one small value. It is a <strong>display-scale</strong> number (about four significant digits), <em>not</em> a lockstep-exact one — keep it out of the deterministic simulation and reach for <code>BigInt</code> / <code>Decimal</code> when exactness matters. Build one with <code>Huge.from</code>, combine with <code>add</code> / <code>sub</code> / <code>mul</code> / <code>neg</code>, compare with <code>cmp</code> / <code>sign</code>, read <code>mantissa</code> / <code>exp</code>, and render as <code>1.23e45</code> with <code>str</code>. Arguments are positional. Spliced in only when a program mentions <code>Huge.*</code>.
