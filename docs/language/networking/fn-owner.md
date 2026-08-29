---
id: fn-owner
name: owner / set_owner
category: networking
kind: builtin
tokens: owner set_owner
sig: owner(e) -> int   set_owner(e, id)
tip: Read or assign an entity's network owner.
order: 2
---

<code>@Owned</code> gives a model an owner slot; <code>owner(e)</code> reads the peer id that owns entity <code>e</code> and <code>set_owner(e, id)</code> assigns it (the authority decides). Ownership gates who may write <code>@Sync(to: owner)</code> fields.
