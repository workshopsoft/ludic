---
id: tiled-layer_kind
name: Tiled.layer_kind
category: tiled
kind: namespace-method
tokens: Tiled.layer_kind
sig: Tiled.layer_kind(map, layer: int) -> int
tip: A layer's kind.
order: 32
ns: Tiled
member: layer_kind
---

Returns a layer's kind: <code>0</code> tile layer, <code>1</code> object layer, <code>2</code> image layer, <code>3</code> group (its children are flattened in after it), or <code>-1</code> out of range.
