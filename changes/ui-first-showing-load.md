bump: patch
type: fix
**A component's first showing, and a screen's pool growing past its most, are loads to the alloc fence; a pool grows
by stretches.** Reading a template and its styles, a screen's first two builds and a pool reaching a new high-water
mark are bounded growth, but in a session that opens something new every few seconds they rose six windows in a row
and the fence ended the run as "declared but unbounded" (`tpl_read`, `sel_new`, `ui_kept`, `value_new`, `mm_join`,
`bd_pass_down` at frame 4199). `uc_load`, `pl_new` and every pool miss now call `Mem.rewarm()`, as a trip starting
does; a pool's Values, scopes, passes and made lines grow by a stretch (half again, 16 at least) as its nodes did, so
a screen reaches its most in a few loads rather than one per Value (166 loads in a driven session's first 4500
frames, where one a Value made 1300, and then only when a screen is first opened); and a pooled node is made with room in its lists (16 children, 8 classes, attributes
and values; a scope 8 names), so an element taking a pooled node later grows none of them. A visit to a screen already
shown is judged as ever: a lab control keeping 64 declared bytes every 300 frames is still reported within 6 windows.
