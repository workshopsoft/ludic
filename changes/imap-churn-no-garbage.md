bump: patch
type: fix
**An `IntMap` whose keys come and go no longer leaves two arrays behind each time it sweeps.** When deleted keys filled an `IntMap` (ids that never repeat: a crowd's actors, a pool's uids), `imap_put` rehashed into a freshly allocated pair of arrays, the old pair never given back, so a map that churned ids allocated every few hundred spawns for ever. The sweep now goes through scratch arrays made once per size (and by `imap_reserve`), and only a real doubling allocates. Regression test under the alloc fence.
