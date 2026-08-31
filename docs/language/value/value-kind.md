---
id: value-kind
name: Value.kind
category: value
kind: namespace-method
tokens: Value.kind
sig: Value.kind(value) -> int
tip: The node's kind tag.
order: 15
ns: Value
member: kind
---

Returns the node's kind: <code>0</code> null, <code>1</code> int, <code>2</code> fixed, <code>3</code> bool, <code>4</code> str, <code>5</code> list, <code>6</code> object — so a generic reader can branch before unwrapping.
