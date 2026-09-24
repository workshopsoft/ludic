---
id: time-sleep_us
name: Time.sleep_us
category: time
kind: namespace-method
tokens: Time.sleep_us
sig: Time.sleep_us(us)
tip: Waits this many microseconds.
order: 8
ns: Time
member: sleep_us
---

Suspends the program for about `us` microseconds - a high-resolution wait, for pacing a loop to a frame rate. No operating system's sleep is exact, so a limiter sleeps most of the wait and spins the last of it.

Parameters:
- `us` — how long to wait, in microseconds (a `long`)

```ludic
program Paced {
  entry {
    Time.sleep_us(1000)
    print(1)
  }
}
```
