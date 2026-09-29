---
id: annot-tint
name: @Tint
category: annotations
kind: annotation
tokens: @Tint
sig: @Color @Tint(SLOT) field: int = 0
tip: A colour for that tint slot.
order: 70
---

<code>@Tint(TSLOT_HAIR)</code> names the tint slot a colour field paints - a constant, which must exist (or, when the program lacks it, is a warning and unresolved).
