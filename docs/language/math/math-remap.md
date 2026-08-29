---
id: math-remap
name: Math.remap
category: math
kind: namespace-method
tokens: Math.remap
sig: Math.remap(v, in0, in1, out0, out1) -> fixed
tip: Rescale a value from one range into another.
order: 10
ns: Math
member: remap
---

Maps <code>v</code> from the input range <code>in0</code>..<code>in1</code> onto the output range <code>out0</code>..<code>out1</code>, keeping its relative position — equivalent to <code>Math.lerp(out0, out1, Math.inverse_lerp(in0, in1, v))</code>. All arguments are <code>fixed</code>. It is the one call that converts between units: a health value into a bar width, a noise sample in <code>-1..1</code> into a <code>0..255</code> shade, or a mouse position into a world coordinate. Swap the output ends to invert the mapping.

Parameters:
- `v` — the value to rescale
- `in0` — the start of the input range
- `in1` — the end of the input range
- `out0` — the start of the output range
- `out1` — the end of the output range

```ludic
program HealthBar {
  const MAX_HP: fixed = 200.0
  const BAR_WIDTH: fixed = 64.0

  var hp: fixed = 150.0

  handler Draw phase Render {
    let width = Math.remap(hp, 0.0, MAX_HP, 0.0, BAR_WIDTH)   # 48.0
  }
}
```
