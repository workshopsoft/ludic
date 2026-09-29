bump: patch
type: fix
**A chunked table's keys are unique across its map, and not interned.** A row's id is `(map, key)`, so a
tree moved into another chunk keeps it, and `ludicc --check` refuses a key written in two of a map's
chunk files, naming both. The keys are no longer interned: interning every key a player walked past would
have filled the bounded intern table and kept them all for good. A chunk slot keeps its keys in its own
buffers, rewritten in place when the slot is refilled; `intern(row.key)` keeps one past `_out`.
