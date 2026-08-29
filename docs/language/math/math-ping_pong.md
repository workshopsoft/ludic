---
id: math-ping_pong
name: Math.ping_pong
category: math
kind: namespace-method
tokens: Math.ping_pong
sig: Math.ping_pong(t, len) -> int
tip: Bounce a counter back and forth in [0, len].
order: 22
ns: Math
member: ping_pong
---

Maps an ever-increasing counter <code>t</code> to a value that rises from <code>0</code> to <code>len</code> and back, bouncing forever — the triangle wave to <code>Math.wrap</code>'s sawtooth. Feed it a frame counter to drive a patrol, a pulsing highlight, or a back-and-forth sweep without tracking direction yourself.

```ludic
program Demo {
  handler Step phase Update {
    let phase = Math.ping_pong(frame, 30)
  }
}
```
