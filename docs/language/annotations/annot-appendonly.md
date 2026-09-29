---
id: annot-appendonly
name: @AppendOnly
category: annotations
kind: annotation
tokens: @AppendOnly @ByKey
sig: @AppendOnly @ByKey registry Name of Record ...
tip: How a registry's entries may change: only appended (their index is saved), or saved by key.
order: 74
---

<code>@AppendOnly</code> on a registry says an entry's index is stored somewhere that outlives the build, so entries are only ever appended; <code>@ByKey</code> says entries are saved by key, so their order is free. Editors keep to what each says.

```ludic
# doc-check: skip — the file it names is beside the example
@AppendOnly @ByKey
registry Tools of Tool as TL from "data/tools.lres"
```
