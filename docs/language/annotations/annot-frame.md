---
id: annot-frame
name: @frame
category: annotations
kind: annotation
tokens: @frame
sig: @frame field: fn() -> void
tip: A fn stored here runs every frame.
order: 76
---

<code>@frame</code> on a function-typed field says whatever function it holds runs every frame, so <code>ludic deps</code> counts what it can allocate among the frame's allocations.
