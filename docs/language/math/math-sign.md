---
id: math-sign
name: Math.sign
category: math
kind: namespace-method
tokens: Math.sign
sig: Math.sign(x) -> int
tip: The sign of a value as -1, 0, or 1.
order: 4
ns: Math
member: sign
---

Returns <code>-1</code> when <code>x</code> is negative, <code>1</code> when it is positive, and <code>0</code> when it is exactly zero. It works on both <code>int</code> and <code>fixed</code> values, since zero and sign are the same in Q16.16. Multiply a step by <code>Math.sign(dx)</code> to move one unit toward a target, or read the sign of a velocity to decide which way a sprite faces.

Parameters:
- `x` — the value to test

```ludic
program FaceTarget {
  state FaceTargetState {
    x: int = 8
  }
  let target: int = 20

  handler StepToward(face_target_st: mut FaceTargetState) phase Update {
    face_target_st.x = face_target_st.x + Math.sign(target - face_target_st.x)   # +1 while target is to the right
  }
}
```
