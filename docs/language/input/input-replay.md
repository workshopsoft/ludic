---
id: input-replay
name: Input.replay
category: input
kind: namespace-method
tokens: Input.replay
sig: Input.replay() -> void
tip: Replay recorded input; poll then reads the tape, not the device.
order: 7
ns: Input
member: replay
---

Rewinds the recording made by <a href="input-record.html"><code>Input.record</code></a> and switches to <em>replay</em> mode: each subsequent <a href="input-poll.html"><code>Input.poll</code></a> returns the next key from the tape instead of the live device, so the recorded session runs again exactly — deterministic replays, demo playback, and the basis of rollback netcode. Past the end of the tape, poll reports no input.

```ludic
program Replaying {
  entry {
    Input.bind("up", 'w')
    Input.record()
    Input.poll()
    Input.replay()
    Input.poll()
    if Input.down("up") { print(1) }
  }
}
```
