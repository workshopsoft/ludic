bump: patch
type: fix

**Correct the element type of a slice indexed by a member-access expression.** `emit_index_addr` set the global `g_addr_ty` to the slice's element type *before* evaluating the index expression, so an index that was itself a struct-field access (`slice[obj.field]`) overwrote it — the load then came back typed as the field, and a following field access failed with "member access on non-aggregate". The slice branch now sets `g_addr_ty` last, matching the raw-pointer branches. Also de-duplicate the `@strcmp` declaration (centralised in the head prelude) so a program that pulls in both the world table and the filesystem prelude links.
