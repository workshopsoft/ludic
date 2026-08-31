---
id: ivec2
title: IVec2
order: 8
---

Integer 2D vector math for tile and grid coordinates, cell offsets, and integer sizes. An <code>IVec2</code> is a pair of whole-number <code>int</code> components (x, y) packed into one value, so it is copied by value and never allocates. Every operation is exact integer arithmetic — no rounding, and bit-identical on every platform. Use it wherever a fractional part would be meaningless; reach for <code>Vector</code> when you need sub-pixel precision. Arguments are positional.
