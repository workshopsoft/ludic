---
id: tiled-load_types
name: Tiled.load_types
category: tiled
kind: namespace-method
tokens: Tiled.load_types
sig: Tiled.load_types(path: string) -> int
tip: Load a project custom-type table.
order: 26
ns: Tiled
member: load_types
---

Loads an <code>objecttypes.xml</code> custom-type table so class/enum properties resolve their defaults; returns the number of types loaded. Each <code>&lt;objecttype&gt;</code> maps to its default <code>&lt;property&gt;</code> list.
