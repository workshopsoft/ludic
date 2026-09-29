---
id: annot-asset
name: @Asset
category: annotations
kind: annotation
tokens: @Asset
sig: @Asset("kind"[, map[, optional]]) field: string = ""
tip: A path to a file of that kind; with map, under each map's directory.
order: 67
---

<code>@Asset("gltf")</code> says a string field names a file of that kind. With <code>map</code> the path is under each map's directory and <code>ludicc --check</code> looks for it in every map, refusing one that lacks it unless the field says <code>optional</code>.
