bump: patch
type: docs
ludic.anim's studio.lres no longer says a rig is the game's: it names the package's own rig, a set's `skeleton` reference to an `AnimSkeletons` row (`model`, `root`, `prefix`; clips are `<prefix>_<clip>`). The studio cannot follow a graph-to-skeleton reference through `rig_table` yet, so a game still writes the rig keys in its own entry (see the comment).
