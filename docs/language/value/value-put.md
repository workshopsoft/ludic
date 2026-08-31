---
id: value-put
name: Value.put
category: value
kind: namespace-method
tokens: Value.put
sig: Value.put(obj, key: string, item) -> value
tip: Set a key on an object; returns the object.
order: 9
ns: Value
member: put
---

Sets member <code>key</code> of the <code>obj</code> node to <code>item</code> (replacing an existing member with the same key) and returns the object. Insertion order is preserved for a stable <a href="json-encode"><code>Json.encode</code></a>.
