---
id: kw-from
name: from
category: structure
kind: keyword
tokens: from
sig: registry ... from "file.lres"  /  def Registry from "file.lres"
tip: The resource file a registry's entries are read from.
order: 66
---

<code>from</code> names the <code>.lres</code> file the compiler reads a registry's entries from, relative to the declaring file (or, in a <code>@PerMap</code> registry, to each map's directory). The entries are checked against the record at build time, and an entry's place in the file is its index.
