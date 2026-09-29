---
id: annot-permap
name: @PerMap
category: annotations
kind: annotation
tokens: @PerMap @Chunked
sig: @PerMap registry Name of Row from "rows.lres"  /  @PerMap @Chunked(n) registry ...
tip: A table whose rows are read per map from that map's directory; @Chunked(n) reads it a chunk at a time.
order: 75
---

A <code>@PerMap</code> registry holds what is on a map rather than in the game: its rows are read when a map loads, from that map's directory, into a state the compiler writes with its verbs (<code>_load</code>, <code>_find</code>, ...). <code>@Chunked(n)</code> reads it in n-by-n-metre chunks from files named by <code>{cx}</code> and <code>{cz}</code>.
