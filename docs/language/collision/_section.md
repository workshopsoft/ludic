---
id: collision
title: Collision
order: 6
---

2D overlap tests on integer coordinates (pixels or tiles). Rectangles are <code>(x, y, w, h)</code> from the top-left; circles are <code>(x, y, r)</code>. Each returns a bool. Squared distances are computed in 64-bit so large coordinates never overflow.
