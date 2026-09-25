bump: minor
type: feature
**Ports: `port Clock { now: fn() -> int, day: fn() -> int = fn first_day }` in a module and
`bind Clock { now: fn game_hours }` where the program is put together.** A module asks for what it
needs through `Clock.now()` without naming - or `uses`-ing - the module that answers. A port used
and never bound, a bind that leaves out a member with no default, a member the port does not have
and a second bind are refused; the binder must see the (exported) port.
