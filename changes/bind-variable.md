bump: minor
type: feature
**`bind Purse { money: g_money }` - a port member bound to a variable.** A member that takes nothing
may name a global instead of a function; the compiler writes the getter in the bind's file, so the
one-line wrapper is gone. A member that takes something is refused a variable.
