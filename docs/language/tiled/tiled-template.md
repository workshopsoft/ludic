---
id: tiled-template
name: Tiled.template
category: tiled
kind: namespace-method
tokens: Tiled.template
sig: Tiled.template(path: string) -> value
tip: Read a template file into an object value.
order: 27
ns: Tiled
member: template
---

Reads a <code>.tx</code>/<code>.tj</code> template file and returns its object <a href="value"><code>Value</code></a> — the reusable object definition an instance inherits. <a href="tiled-load"><code>Tiled.load</code></a> resolves each object's <code>template</code> reference automatically, merging the template's fields under the instance's overrides.
