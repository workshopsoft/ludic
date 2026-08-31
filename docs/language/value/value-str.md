---
id: value-str
name: Value.str
category: value
kind: namespace-method
tokens: Value.str
sig: Value.str(s: string) -> value
tip: Wrap a string in a value node.
order: 5
ns: Value
member: str
---

Builds a <code>str</code> node (kind <code>4</code>) holding <code>s</code>. <a href="json-encode"><code>Json.encode</code></a> quotes and escapes it; read it back with <a href="value-as_str"><code>Value.as_str</code></a>.
