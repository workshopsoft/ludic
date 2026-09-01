---
id: xml-text
name: Xml.text
category: xml
kind: namespace-method
tokens: Xml.text
sig: Xml.text(node) -> string
tip: The element's character data.
order: 3
ns: Xml
member: text
---

Returns the concatenated character data of <code>node</code> — the CSV inside a <code>&lt;data encoding="csv"&gt;</code> element, or a <code>&lt;property&gt;</code> value, lands here (entity-decoded).
