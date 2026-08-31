---
id: json-parse
name: Json.parse
category: json
kind: namespace-method
tokens: Json.parse
sig: Json.parse(text: string) -> value
tip: Parse JSON text into a value tree.
order: 2
ns: Json
member: parse
---

Parses JSON <code>text</code> into a value tree — the inverse of <a href="json-encode"><code>Json.encode</code></a>. Numbers with a decimal point become <code>fixed</code> nodes (recovered bit-for-bit from a value written by <code>Json.encode</code>), whole numbers <code>int</code> nodes. It is a lean, best-effort reader for trusted saves, not a validating parser; feed a parsed object to <a href="reflect-apply"><code>Reflect.apply</code></a> to load it into an entity.
