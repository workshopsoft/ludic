---
id: annot-deterministic
name: @deterministic
category: annotations
kind: annotation
tokens: @deterministic
sig: @deterministic function f() { }
tip: No floating point inside: it must replay the same everywhere.
order: 79
---

<code>@deterministic</code> on a function or a handler refuses floating point inside it, so it computes the same bits on every machine - what lockstep and replays need.
