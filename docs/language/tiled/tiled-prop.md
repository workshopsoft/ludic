---
id: tiled-prop
name: Tiled.prop
category: tiled
kind: namespace-method
tokens: Tiled.prop
sig: Tiled.prop(container, name: string) -> string
tip: A custom property's value, with class-default fallback.
order: 23
ns: Tiled
member: prop
---

Returns the string value of custom property <code>name</code> on <code>container</code> (an object / tile / layer / map), falling back to the container class's default from the project custom-type table (<a href="tiled-load_types"><code>Tiled.load_types</code></a>). <code>""</code> when absent everywhere.
