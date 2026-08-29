---
id: time
title: Time
order: 6
---

The frame clock. <code>frame</code>/<code>elapsed</code>/<code>delta</code> are deterministic (driven by a per-frame counter at a fixed 60 fps), so a replay reproduces every value; <code>now</code> is the wall clock and is explicitly non-deterministic.
