---
id: vector
title: Vector
order: 7
---

2D vector math for positions, velocities, and directions. A <code>Vector</code> is a pair of Q16.16 fixed components packed into one value, so it is copied by value and never allocates. Every operation is deterministic integer fixed-point — bit-identical on every platform, the same guarantee the rest of the runtime gives. Arguments are positional; angles are in radians.
