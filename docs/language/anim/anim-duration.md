---
id: anim-duration
name: Anim.duration
category: anim
kind: namespace-method
tokens: Anim.duration
sig: Anim.duration(fps, count) -> fixed
tip: Seconds for one full cycle of a clip: count / fps.
order: 5
ns: Anim
member: duration
---

Returns the length of one cycle of a clip in seconds as a <code>fixed</code>: <code>count / fps</code>. Handy to schedule the next event, size a progress bar, or line a tween up with an animation.

Parameters:
- `fps` — frames per second
- `count` — number of frames in the clip

```ludic
program Demo {
  handler Run phase Update {
    let secs = Anim.duration(12, 4)   # 4 frames / 12 fps = 0.333s
    print(secs)
  }
}
```
