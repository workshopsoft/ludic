---
id: annot-node
name: @Node
category: annotations
kind: annotation
tokens: @Node @Clip @Material
sig: @Node(model) / @Clip(model) / @Material(model) field: string = ""
tip: A node, an animation clip or a material inside the glTF another field names.
order: 69
---

<code>@Node(model)</code>, <code>@Clip(model)</code> and <code>@Material(model)</code> say a string field names a node, a clip or a material inside the glTF that field <code>model</code> of the same record names (an <code>@Asset("gltf")</code> field, or an <code>@Ref</code> to a registry whose record has exactly one). Naming anything else is an error.
