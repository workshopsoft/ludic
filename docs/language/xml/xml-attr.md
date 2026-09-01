---
id: xml-attr
name: Xml.attr
category: xml
kind: namespace-method
tokens: Xml.attr
sig: Xml.attr(node, key: string) -> string
tip: An attribute's value by name.
order: 4
ns: Xml
member: attr
---

Returns the value of attribute <code>key</code> (entity-decoded), or <code>""</code> if the element has no such attribute. Use <a href="xml-has"><code>Xml.has</code></a> to distinguish an empty value from an absent one.
