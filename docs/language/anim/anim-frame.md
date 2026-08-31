---
id: anim-frame
name: Anim.frame
category: anim
kind: namespace-method
tokens: Anim.frame
sig: Anim.frame(timer, fps, count) -> int
tip: The looping frame index for an elapsed timer at a given fps.
order: 1
ns: Anim
member: frame
---

Returns the current frame of a looping clip: <code>floor(timer * fps)</code> reduced modulo <code>count</code>. <code>timer</code> is elapsed seconds as a <code>fixed</code>, <code>fps</code> the clip's frames per second, and <code>count</code> the number of frames. The clip wraps forever — frame <code>count-1</code> is followed by frame <code>0</code>.

Parameters:
- `timer` — elapsed seconds (a `fixed`)
- `fps` — frames per second
- `count` — number of frames in the clip

```ludic
program Demo {
  property Sprite { timer: fixed = 0.0 }
  model Hero { Sprite }
  handler Run phase Update {
    Sprite.timer = Sprite.timer + Time.delta()
    let cell = Anim.frame(Sprite.timer, 12, 4)   # 4-frame run at 12 fps
    print(cell)
  }
}
```
