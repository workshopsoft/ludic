---
id: annot-rowverb
name: @RowVerb
category: annotations
kind: annotation
tokens: @RowVerb
sig: @RowVerb function deer_move(r: mut Row<Deer>, x: float) -> void
tip: A verb of a table's row: the only function a row reducer hands its row to.
order: 83
---

<code>@RowVerb</code> marks a function that changes one row of a table, taking the <code>Row&lt;T&gt;</code> first. It is declared in the module that owns the record, reaches the row's table (<code>r.tb</code>, <code>r.row</code>) to keep its columns and indexes, and is the only function a row reducer may hand its row to; a function not marked so is refused a row.

```ludic
@RowVerb function deer_move(r: mut Row<Deer>, x: float) -> void {
  r.rec.x = x
  tb_set_f(r.tb, 0, r.row, x)
}
```
