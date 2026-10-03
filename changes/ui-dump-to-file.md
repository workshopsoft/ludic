bump: patch
type: fix
**`ui_dump_to(root, path)` writes a laid-out tree to a file and keeps nothing.** An editor's live link asks for the
tree (`ui_tree`) again and again; `ui_dump`'s text, joined a piece at a time (and `ui_hex` per colour), kept every
piece for good - 25 MB over 36000 frames of a driven session. `ui_dump_to` writes the same lines into one buffer it
lets go once the file is written. `tests/ui_dump_to_test`: the file is what `ui_dump` prints, and 200 dumps grow the
heap by under 4 KB.
