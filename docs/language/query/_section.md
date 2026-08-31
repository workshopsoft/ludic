---
id: query
title: Query
order: 30
---

Spatial and set queries over the live entities that carry a property, built on the <a href="world"><code>World</code></a> reflection ABI. <a href="query-count"><code>Query.count</code></a> and <a href="query-first"><code>Query.first</code></a> ask how many bearers there are and which is first; <a href="query-nearest"><code>Query.nearest</code></a> and <a href="query-within"><code>Query.within</code></a> add a position — read from a coordinate property's two int fields — to find the closest entity to a point or every entity inside a radius. A property id comes from <a href="world-prop_id"><code>World.prop_id</code></a> and a field id from <a href="world-field_id"><code>World.field_id</code></a>. Everything is integer and deterministic: the same world reproduces the same answers, entity order included, every run. The scan is linear over the entity table — ample for the entity counts Ludic targets — and a game that uses <code>Query.*</code> gets the reflection ABI emitted automatically, no <code>@event</code> required.
