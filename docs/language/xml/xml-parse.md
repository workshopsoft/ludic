---
id: xml-parse
name: Xml.parse
category: xml
kind: namespace-method
tokens: Xml.parse
sig: Xml.parse(text: string) -> xml
tip: Parse XML text into an element tree.
order: 1
ns: Xml
member: parse
---

Parses an XML document and returns its root element (or an empty node if there is none). Handles nested elements, single- and double-quoted attributes, text/<code>&lt;![CDATA[…]]&gt;</code> content, comments, the <code>&lt;?xml?&gt;</code> prolog and <code>&lt;!DOCTYPE&gt;</code>. Best-effort, not validating.
