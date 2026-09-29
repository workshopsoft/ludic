---
id: annot-range
name: @Range
category: annotations
kind: annotation
tokens: @Range
sig: @Range(lo, hi) field: float = 0.0
tip: The least and the most the value may be.
order: 65
---

<code>@Range(0, 20.5)</code> gives an editor the bounds of a number field, and <code>ludicc --check</code> holds every map row's value to them. Both arguments are numbers.
