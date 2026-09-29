---
id: annot-ref
name: @Ref
category: annotations
kind: annotation
tokens: @Ref
sig: @Ref(Registry) field: int = 0
tip: The field is an entry of that registry: an index, or a key for a @PerMap one.
order: 63
---

<code>@Ref(Items)</code> on a field says its value is an entry of the registry <code>Items</code> - its index on an <code>int</code> field, its key on a <code>string</code> field of a <code>@PerMap</code> table - so an editor offers the entries. It changes nothing the program does; a registry the program does not declare is a warning and <code>"unresolved"</code> in the schema, anything else of that name is an error.

```ludic
# doc-check: skip — the registry is declared elsewhere
property Tool {
  @Ref(Vendors) seller: int = 0
}
```
