---
id: input-record
name: Input.record
category: input
kind: namespace-method
tokens: Input.record
sig: Input.record() -> void
tip: Start recording polled input each frame (for deterministic replay).
order: 6
ns: Input
member: record
---

Puts input into <em>record</em> mode and resets the tape: from now on each <a href="input-poll.html"><code>Input.poll</code></a> reads the live key and appends it to a recording. Because the simulation is deterministic in its input stream, that tape is all you need to reproduce a run — play it back with <a href="input-replay.html"><code>Input.replay</code></a> for a free exact replay, the seed of lockstep netcode. Recording captures input only; it does not change what the game sees this frame.

```ludic
program Recording {
  entry {
    Input.bind("up", 'w')
    Input.record()
    Input.poll()
    if Input.down("up") { print(1) }
  }
}
```
