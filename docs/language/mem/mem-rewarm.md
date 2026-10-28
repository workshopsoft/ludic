---
id: mem-rewarm
name: Mem.rewarm
category: mem
kind: namespace-method
tokens: Mem.rewarm
sig: Mem.rewarm() -> void
tip: Re-arm the warm-up (the same call as Mem.play).
order: 6
ns: Mem
member: rewarm
---

Re-arms the warm-up after a one-time build, exactly as <a href="mem-play"><code>Mem.play()</code></a> does: it compiles to the same call. Pair it with <a href="mem-settled"><code>Mem.settled()</code></a> to make what is held now the new floor.
