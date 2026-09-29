---
id: kw-registry
name: registry
category: structure
kind: keyword
tokens: registry
sig: [open] registry Name of Record [as PREFIX] [from "file.lres"]
tip: A table of named entries of one record type, with a constant per entry.
order: 63
---

A <code>registry</code> is a table of named entries of one record: its entries come from <code>def</code> declarations or a resource file named by <code>from</code>, and <code>as P</code> generates a constant <code>P_KEY</code> per entry holding its index. Editors read it through <code>ludic schema</code>, and attributes such as <code>@AppendOnly</code> and <code>@PerMap</code> say how its entries may change and where they live.

```ludic
# doc-check: skip — the file it names is beside the example
property Tool { key: string = "", weight: float = 0.0 }
registry Tools of Tool as TL from "data/tools.lres"
```
