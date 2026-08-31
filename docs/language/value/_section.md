---
id: value
title: Value
order: 35
---

A generic, self-describing value tree — the node type reflection serializes into and JSON round-trips through. A node is one of null, <code>int</code>, <code>fixed</code>, <code>bool</code>, <code>str</code>, <code>list</code>, or <code>object</code> (see <a href="value-kind"><code>Value.kind</code></a>). Build one with the constructors (<a href="value-int"><code>Value.int</code></a>, <a href="value-object"><code>Value.object</code></a>, …) and the builders <a href="value-add"><code>Value.add</code></a>/<a href="value-put"><code>Value.put</code></a>; read it with <a href="value-get"><code>Value.get</code></a>/<a href="value-at"><code>Value.at</code></a>/<a href="value-count"><code>Value.count</code></a> and the <code>as_*</code> accessors. Related: <a href="json"><code>Json</code></a>, <a href="reflect"><code>Reflect</code></a>.
