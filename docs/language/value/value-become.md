---
id: value-become
name: Value.become
category: value
kind: namespace-method
tokens: Value.become
sig: Value.become(value, tag) -> Value
tip: Turn a node into a blank one of another kind.
order: 42
ns: Value
member: become
---

Turns <code>value</code> into a blank node of kind <code>tag</code> (the runtime's numeric kind code), keeping and emptying its own lists, and returns it. For a pool that hands the same records out again. Prefer <a href="value-be_int"><code>Value.be_int</code></a>, <a href="value-be_float"><code>Value.be_float</code></a> and <a href="value-be_str"><code>Value.be_str</code></a>.
