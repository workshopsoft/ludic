bump: patch
type: feature
**`ludic deps --writes` warns about a write through a local alias.** `let t = thing_cur` and then
`t.used = 1` writes another module's record just as `thing_cur.used = 1` does; a local bound straight
from another module's global (or from such a local) is now followed within its function and each
write through it listed as a warning. A reference that arrives from a function's result is not.
