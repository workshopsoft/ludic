---
id: kw-fn
name: fn
category: structure
kind: keyword
tokens: fn
sig: fn name
tip: A top-level function named as a value - the entry point handed to Job.parallel_for.
order: 9
---

<code>fn name</code> names a top-level function as a value, so it can be handed to something that calls it later - today, <code>Job.parallel_for</code>, which runs it on worker threads. It is a plain function reference: no closure and nothing captured, so everything the function needs is passed to it (for <code>Job.parallel_for</code>, through its <code>ctx</code> argument). A worker function takes <code>(i: int, ctx)</code> and returns <code>void</code>; the compiler rejects any other shape.

```ludic
program Squares {
  function square(i: int, out: words) -> void { out[i] = i * i }

  entry {
    let sq = words(1000)
    Job.parallel_for(1000, fn square, sq)
    print(sq[12])
  }
}
```
