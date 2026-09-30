---
id: annot-column
name: @Column
category: annotations
kind: annotation
tokens: @Column
sig: property Deer { @Column x: float = 0.0 }
tip: A record's field a column of its table mirrors: written only by a @RowVerb.
order: 82
---

<code>@Column</code> marks a field of a table's record that one of the table's columns mirrors - a position, a kind, whether it is alive - so an index reads it. Inside a row reducer it is not written through <code>r.rec</code>: a <code>@RowVerb</code> writes it, and the column and its indexes with it.

```ludic
property Deer {
  @Column x: float = 0.0
  fear: int = 0
}
```
