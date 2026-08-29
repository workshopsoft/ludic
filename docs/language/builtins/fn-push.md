---
id: fn-push
name: push
category: builtins
kind: builtin
tokens: push
sig: push(slice, x)
tip: Append one element to the end of a growable slice.
order: 6
---

Appends a value to the end of a slice, growing it by one element. Create the slice first with <code>new []T</code>, then <code>push</code> items onto it; afterward <code>len</code> reflects the new count and the element is reachable by index. Use it to build up lists at runtime — a queue of spawn requests, collected scores, parsed tokens — where you don't know the size in advance. The value's type must match the slice's element type.

Parameters:
- `slice` — the growable slice to append to
- `x` — the element to append

```ludic
program BuildWaveList {
  handler PlanWaves phase Start {
    let wave_sizes = new []int
    push(wave_sizes, 4)
    push(wave_sizes, 6)
    for index in 0 .. len(wave_sizes) {
      print(wave_sizes[index])
    }
  }
}
```
