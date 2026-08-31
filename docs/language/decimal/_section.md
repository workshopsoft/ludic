---
id: decimal
title: Decimal
order: 11
---

Exact base-10 fixed-point numbers for game economies — prices, balances and taxes on values like <code>0.10</code> that binary floating point cannot represent, so they always add up exactly. A <code>Decimal</code> is a <code>BigInt</code> mantissa with a decimal <code>scale</code> (the number of digits after the point), giving unbounded range and exact <code>add</code> / <code>sub</code> / <code>mul</code>. Build one with <code>Decimal.from</code> (an <code>int</code>) or <code>Decimal.parse</code> (text like <code>"19.99"</code>), compare with <code>cmp</code> / <code>eq</code>, change precision with <code>rescale</code> (truncates toward zero), read the current precision with <code>scale</code>, and render with <code>str</code>. Every operation is exact and deterministic. The runtime is spliced in only when a program mentions <code>Decimal.*</code> (or <code>BigInt.*</code>).
