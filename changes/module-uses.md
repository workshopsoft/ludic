bump: minor
type: feature
**`module fishing uses base, data` - a module declares what it may reach, and the compiler holds it
to that.** A reference from a module that says `uses` into a module it does not name is refused,
exported or not, with the use and the fix in the message ("fishing uses items.inv_add (...): add
'uses items' to fishing's module line, or take it through a port"). A module with no `uses` keeps
the old rule, a package's module is always usable, a friend is not held to it, a cycle in the
declared graph is refused, and `LUDIC_VIS_REPORT=1` lists the violations as `uses:` lines.
