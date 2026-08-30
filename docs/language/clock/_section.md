---
id: clock
title: Clock
order: 6
---

A game-controlled simulated clock: a single seconds counter the game owns. Unlike <code>Time.now</code> / <code>Time.since</code>, it never reads the wall clock, so any gameplay that reads <code>Clock.now()</code> is deterministic and replay-safe. Set it outright, or advance it by a <code>Duration</code> each tick to run time at whatever rate the simulation wants. The clock is a plain instant (seconds since 1970), so all the <code>DateTime.*</code> readers work on it directly.
