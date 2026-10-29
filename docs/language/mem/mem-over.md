---
id: mem-over
name: Mem.over
category: mem
kind: namespace-method
tokens: Mem.over
sig: Mem.over(what: string) -> void
tip: Report that a package table is full.
order: 7
ns: Mem
member: over
---

Tells the fence that the table named by <code>what</code> has filled. Under <code>R3D_ALLOC_FENCE=count</code> it is only counted; under <code>warn</code> it prints the name; under <code>fail</code> it prints and the run exits with code 87, as a table that overflows its <code>@max</code> cap does. Silent when the fence is off.
