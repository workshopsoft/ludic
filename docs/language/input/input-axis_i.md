---
id: input-axis_i
name: Input.axis_i
category: input
kind: namespace-method
tokens: Input.axis_i
sig: Input.axis_i(neg, pos) -> int
tip: A -1/0/1 directional intent as a plain int, no bool->int glue.
order: 14
ns: Input
member: axis_i
---

Returns a directional intent as a plain <code>int</code>: <code>+1</code> when the positive key is held, <code>-1</code> when the negative one is, <code>0</code> for neither or both. It reads the multi-key device set, so it replaces the <code>ki(key_down('d')) - ki(key_down('a'))</code> boolean-to-int boilerplate and feeds an int mover directly — <code>dx = Input.axis_i('a', 'd')</code>, <code>dy = Input.axis_i('w', 's')</code>. For an analog / normalized value use <a href="input-axis.html"><code>Input.axis</code></a> (fixed) or <a href="input-vector.html"><code>Input.vector</code></a>.

```ludic
program Demo {
  entry {
    Input.press('d')
    Input.poll()
    print(Input.axis_i('a', 'd'))     # 1
  }
}
```
