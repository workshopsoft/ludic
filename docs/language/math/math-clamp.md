---
id: math-clamp
name: Math.clamp
category: math
kind: namespace-method
tokens: Math.clamp
sig: Math.clamp(v, lo, hi) -> int
tip: Constrain a value to the range [lo, hi].
order: 3
ns: Math
member: clamp
---

Returns <code>v</code> held inside the inclusive range <code>lo</code>..<code>hi</code>: below <code>lo</code> it returns <code>lo</code>, above <code>hi</code> it returns <code>hi</code>, otherwise <code>v</code> unchanged. It is the single-call form of <code>Math.max(lo, Math.min(v, hi))</code> and works for <code>int</code> and <code>fixed</code> alike. Use it to keep a camera inside the world, a slider within its track, or a stat within its legal bounds. The bare form <code>clamp(v, lo, hi)</code> is kept as a convenience alias.

Parameters:
- `v` — the value to constrain
- `lo` — the lowest allowed result (inclusive)
- `hi` — the highest allowed result (inclusive)

```ludic
program CameraBounds {
  const WORLD_WIDTH: int = 320

  state CameraBoundsState {
    camera_x: int = 0
  }

  handler Follow(camera_bounds_st: mut CameraBoundsState) phase Update {
    camera_bounds_st.camera_x = Math.clamp(camera_bounds_st.camera_x, 0, WORLD_WIDTH - 1)
  }
}
```
