---
id: json-encode
name: Json.encode
category: json
kind: namespace-method
tokens: Json.encode
sig: Json.encode(value) -> string
tip: Serialize a value tree to compact JSON text.
order: 1
ns: Json
member: encode
---

Walks a value tree and returns compact JSON text. <code>int</code> nodes become integers, <code>fixed</code> nodes an exact decimal, <code>bool</code> <code>true</code>/<code>false</code>, <code>str</code> a quoted (escaped) string, and lists/objects the usual <code>[…]</code>/<code>{…}</code> — object members keep insertion order, so the output is stable and diffable. The inverse is <a href="json-parse"><code>Json.parse</code></a>; together with <a href="reflect-serialize"><code>Reflect.serialize</code></a> this is a one-call save.
