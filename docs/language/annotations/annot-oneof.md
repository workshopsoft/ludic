---
id: annot-oneof
name: @OneOf
category: annotations
kind: annotation
tokens: @OneOf
sig: @OneOf(PREFIX_) / @OneOf(A, B) / @OneOf("word", ...)
tip: The field holds one of these constants or words.
order: 64
---

<code>@OneOf(GR_)</code> says a field holds one of the constants whose names start <code>GR_</code>; <code>@OneOf(GR_GOLD, GR_SILVER)</code> one of those (each must exist); on a <code>string</code> field, <code>@OneOf("box", "hull")</code> one of those words, and every registry row is checked against them.
