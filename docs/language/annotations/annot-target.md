---
id: annot-target
name: @Target
category: annotations
kind: annotation
tokens: @Target
sig: action Spook { @Target who: int = -1 }
tip: An action's field holding the handle of the one table row it names.
order: 81
---

<code>@Target</code> marks the field of an <code>action</code> that holds a row's handle - what <code>tb_add</code> returned. A row reducer (<code>reducer Deer in Herd.deer on Spook</code>) runs once, for that row alone, and a handle whose row is gone runs nothing. An action has one: several rows are one <code>dispatch</code> per handle.

```ludic
action Spook { @Target who: int = -1, by: int = 1 }
```
