---
id: fn-len
name: len
category: builtins
kind: builtin
tokens: len
sig: len(x) -> int
tip: The number of elements in a slice, or the byte length of a string.
order: 5
---

Returns the length of its argument: the element count of a slice, or the byte length of a string. Use it to iterate a slice with <code>for index in 0 .. len(items)</code>, to check whether a collection is empty, or to compute string slice bounds such as trimming a suffix. It reads the current length, so after you <code>push</code> onto a slice the value it returns grows accordingly. For strings, note it counts bytes, not visual characters.

Parameters:
- `x` — a slice or string to measure

```ludic
program CountEnemies {
  handler ReportCount phase Start {
    let wave_sizes = new []int
    push(wave_sizes, 3)
    push(wave_sizes, 5)
    push(wave_sizes, 8)
    print(len(wave_sizes))
  }
}
```
