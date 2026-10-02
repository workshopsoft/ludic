---
id: annot-asset
name: @Asset
category: annotations
kind: annotation
tokens: @Asset
sig: @Asset("kind"[, map][, optional]) field: string = ""
tip: A path to a file of that kind; with map, under each map's directory; with optional, a row may leave it out.
order: 67
---

<code>@Asset("gltf")</code> says a string field names a file of that kind. With <code>map</code> the path is under each map's directory and <code>ludicc --check</code> looks for it in every map, refusing one that lacks it unless the field says <code>optional</code>. Without <code>map</code>, <code>optional</code> tells an editor that a row may leave the field empty: <code>@Asset("png", optional)</code>. A field that says both says <code>map</code> first: <code>@Asset("png", map, optional)</code>.
