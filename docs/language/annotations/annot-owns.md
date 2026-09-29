---
id: annot-owns
name: @owns
category: annotations
kind: annotation
tokens: @owns @creates @releases
sig: @owns(Kind) field  /  @creates(Kind) function  /  @releases(Kind) function
tip: Resource handles: a field that owns one, a function that makes one, a function that lets one go.
order: 78
---

<code>@creates(PhysShape)</code> on a function says it returns a handle the caller must release, <code>@releases(PhysShape)</code> that it releases one, and <code>@owns(PhysShape)</code> on a field that its record owns the handle it holds. <code>ludic deps --resources</code> counts a created handle never released, and an owned one lost when its record is released.
