---
id: xml
title: Xml
order: 40
---

A minimal, deterministic XML reader for the element/attribute/CDATA subset the native Tiled formats (TMX/TSX/TX) use. <a href="xml-parse"><code>Xml.parse</code></a> turns a document into an element tree; the accessors read a node's <a href="xml-tag"><code>tag</code></a>, <a href="xml-text"><code>text</code></a>, attributes (<a href="xml-attr"><code>Xml.attr</code></a>/<a href="xml-attr_int"><code>Xml.attr_int</code></a>/<a href="xml-has"><code>Xml.has</code></a>) and children (<a href="xml-child"><code>Xml.child</code></a>/<a href="xml-find"><code>Xml.find</code></a>/<a href="xml-count"><code>Xml.count</code></a>). It expands the five predefined entities and numeric character references, skips the <code>&lt;?xml?&gt;</code> prolog, comments and <code>&lt;!DOCTYPE&gt;</code>, and is best-effort rather than validating — the same contract as <a href="json"><code>Json</code></a>. Spliced on demand when a program mentions <code>Xml.*</code>.
