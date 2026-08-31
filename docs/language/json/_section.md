---
id: json
title: Json
order: 36
---

The text bridge over the <a href="value"><code>Value</code></a> tree: <a href="json-encode"><code>Json.encode</code></a> turns a value tree into compact, stable JSON text and <a href="json-parse"><code>Json.parse</code></a> reads it back. Together with <a href="reflect-serialize"><code>Reflect.serialize</code></a>/<a href="reflect-apply"><code>Reflect.apply</code></a> this is a one-call, bit-exact save/load for entities, and a diffable on-disk format for tooling. Determinism holds: the same tree always encodes to the same bytes.
