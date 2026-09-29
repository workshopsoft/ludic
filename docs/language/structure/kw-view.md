---
id: kw-view
name: view
category: structure
kind: keyword
tokens: view
sig: view Name[(states)] { field = expr, function q(...), on e(...) { } }
tip: The bridge to a template: what it may read and what it may do.
order: 72
---

A <code>view</code> says what a template may read (its fields, each an expression) and what it may do (its queries and its <code>on</code> events), and nothing else crosses. The compiler writes <code>view_name()</code>, whose model is a value object of every field and whose call runs a query or an event by name.

```ludic
# doc-check: skip — the functions it names are elsewhere
view Yard {
  spots: int = yard_spots()
  on buy(hf: int) { yard_buy(hf) }
}
```
