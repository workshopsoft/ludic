---
id: rect
title: Rect
order: 9
---

Axis-aligned rectangles for HUD layout boxes, hitboxes, and camera regions. A <code>Rect</code> is four Q16.16 <code>fixed</code> components — position <code>(x, y)</code> (its top-left corner) and size <code>(w, h)</code> — packed into a single value that is copied by value and never allocates. It offers fast point-in-rect and rectangle-overlap tests. Every operation is deterministic fixed-point, bit-identical on every platform. Arguments are positional.
