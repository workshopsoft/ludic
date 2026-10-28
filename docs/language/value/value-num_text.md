---
id: value-num_text
name: Value.num_text
category: value
kind: namespace-method
tokens: Value.num_text
sig: Value.num_text(value) -> string
tip: A number's text, kept until it changes.
order: 41
ns: Value
member: num_text
---

Returns the text of an int, fixed or float node, kept on the node until the number changes, so a count shown every frame writes its text once. An empty string for any other kind.
