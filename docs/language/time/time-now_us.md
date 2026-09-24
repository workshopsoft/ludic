---
id: time-now_us
name: Time.now_us
category: time
kind: namespace-method
tokens: Time.now_us
sig: Time.now_us() -> long
tip: A microsecond clock, for measuring.
order: 7
ns: Time
member: now_us
---

Returns a steady microsecond count from the platform clock, for timing a piece of work - the difference between two readings is how long it took. It is not the game's time (that is <a href="time-now"><code>Time.now</code></a>) and it does not stop when the game is paused.

```ludic
program Timed {
  entry {
    let t0 = Time.now_us()
    print(Time.now_us() - t0)
  }
}
```
