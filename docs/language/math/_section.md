---
id: math
title: Math
order: 6
---

Deterministic fixed-point math. Every function is computed in Q16.16 with plain integer arithmetic, so results are bit-identical on every platform and every run — the same guarantee the rest of the runtime gives. Arguments are positional.

Given a <code>float</code> or <code>double</code> argument, the same functions compute in that type instead (using the platform's math library) and return it — <code>floor</code>, <code>ceil</code> and <code>round</code> included, which return an <code>int</code> only for <code>fixed</code>. <code>sign</code> returns an <code>int</code> either way. <code>trunc</code> and <code>atan</code> exist only for floats.
