---
id: angle-diff_degrees
name: Angle.diff_degrees
category: angle
kind: namespace-method
tokens: Angle.diff_degrees
sig: Angle.diff_degrees(a: int, b: int) -> int
tip: The signed difference between two headings in whole degrees.
order: 20
ns: Angle
member: diff_degrees
---

<code>b - a</code> wrapped into -180 .. 180, for integer-degree headings such as <code>TopDown.aim_angle</code> and <code>IVec2.heading</code>.

```ludic
# doc-check: skip — illustrative
if abs(Angle.diff_degrees(a: aim, b: IVec2.heading(hero, foe))) <= 50 { hit() }
```
