---
id: anim-pingpong
name: Anim.pingpong
category: anim
kind: namespace-method
tokens: Anim.pingpong
sig: Anim.pingpong(timer, fps, count) -> int
tip: A frame index that bounces 0..count-1..0 and repeats.
order: 3
ns: Anim
member: pingpong
---

Returns a frame index that plays forward to <code>count-1</code>, then back to <code>0</code>, then forward again — a triangle wave over the frames. Ideal for a two-way idle bob or a breathing/pulsing loop where a plain wrap would snap.

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `fps` — frames per second
- `count` — number of frames in the clip

```ludic
program Demo {
  property Idle { timer: fixed = 0.0 }
  model Fish { Idle }
  handler Run phase Update {
    Idle.timer = Idle.timer + Time.delta()
    let cell = Anim.pingpong(Idle.timer, 8, 4)   # 0 1 2 3 2 1 0 1 ...
    print(cell)
  }
}
```
