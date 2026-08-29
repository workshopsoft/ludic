---
id: kw-for
name: for … in
category: control
kind: keyword
tokens: for
sig: for name in a .. b { … }
tip: Range loop.
order: 2
---

Range loop. <b>Each pass binds a fresh, immutable <code>name</code></b> — it is not a variable you reuse or reassign; the range <code>a .. b</code> runs from <code>a</code> up to but not including <code>b</code>.

```ludic
for gy in 0 .. GRID_H { … }
```
