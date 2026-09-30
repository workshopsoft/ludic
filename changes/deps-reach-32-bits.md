bump: patch
type: fix
**`ludic deps`: a reach counts every state apart, however the states are numbered.** The reach and
write-reach bitsets packed 60 states to a word, but an `int` is 32 bits, so `1 << 45` came back as bit
13 and states 32 apart shared a bit: a function taking both counted one, fewer than it takes, and the
counts (`widest_reach`, `widest_write_reach`, `--reach`, `--wreach`) rose and fell with how a program's
states happened to be numbered. The sets now hold 30 to a word. On Maroon Lake `widest_reach` goes
58 -> 76 and `widest_write_reach` 54 -> 64 - the real numbers, which the old count hid.
`examples/state/reach_wide.ludic` (40 states, S00 and S32 taken together) holds it.
