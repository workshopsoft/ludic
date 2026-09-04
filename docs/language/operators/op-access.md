---
id: op-access
name: Member & index
category: operators
kind: operator
sig: x.field   buffer[i]   text[a..b]
tip: Field access, element index, and string slice — usable as value or target.
order: 6
---

The access operators reach into a compound value. `value.field` reads or writes a property field and chains freely (`route.next.column`); `buffer[index]` reads or writes one element of a slice or raw buffer; and `text[start..end]` produces a fresh substring of the bytes in the half-open range, while `text[index]` reads a single byte as an `int` code point. Each form works both as a <b>value</b> and as an <b>assignment target</b>, and they compose — `route[index].column = 0` is one address computation. Field access also binds method-style calls like `Screen.fill_rectangle`.

```ludic
let head_column: int = segments[0].column
segments[0].column = head_column + 1
let extension: string = file_name[len(file_name) - 4..len(file_name)]
```
