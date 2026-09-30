bump: minor
type: feat
**A state machine as data: `@Machine(Record.field)`** (phase 27.1). A registry marked
`@Machine(Deer.mood)` is the transitions of a machine over that enum field of the records a state's
`Table<Deer>` holds: its record has `from` and `to` (the enum's variants), `on: string` (an action's
name, `""` for a transition the tick asks), `guard: fn(Row<Deer>, reads...) -> bool` and
`enter: fn(Row<Deer>, reads...) -> void`; the states are the enum's variants and the start is the
field's default. Its rows are data - an `.lres` or `def`s - so the studio edits the machine as a graph.

- **The compiler writes the machine.** For each action an `on` names, a row reducer in the
  registry's file (`reducer Deer in Herd.deer on Spook`, beside any the program writes, after them):
  the row's state, the first transition from it on that action whose guard passes, the field set,
  `enter` run. When a row leaves a state on a guard alone, `state DeerStepsMachine` (the kept row
  view) and `deer_steps_tick(m: mut DeerStepsMachine, s: mut Herd, reads...)`, one transition a row
  a tick, called from the program's system. Guards and enters are called by name; nothing allocates.
- **The table is the whole machine.** The field is written by nothing else: an assignment to it or
  a `machine` block's `become` over it outside the written code is a type error (`Deer.mood is the
  machine DeerSteps's (@Machine(Deer.mood)) - it changes only by a transition in its table`); a new
  row takes its state in its `new`. A guard and an enter take the row first, are the record's
  module's, and keep a row reducer's rules (`r.rec` and `r.h` only, a `@Column` field only through a
  `@RowVerb`); a guard writes nothing through its row.
- **The graph is checked**, each an error naming its row: a state never reached from the start, a
  state with no way out, an `on` naming no action or an action with no `@Target`, a self-transition
  with no guard, and two ways out of a state on one trigger behind an unguarded first. Also refused:
  `@Machine` on anything but a registry, a field that is not a plain enum with a default, a
  `@Column` field, no table (or two) of the record, a transitions record of another shape, and a
  machine outside its table's state's module.
- **`ludic schema`'s code section** gains `machines` (`registry`, `record`, `field`, `enum`, `table`,
  `start`, `states`, `actions`, `tick`, `module`, `at`); the registry carries `@Machine` among its
  attributes. `ludic deps` names a machine's reducer `reducer Deer in Herd.deer on Spook (machine
  DeerSteps)`. vocab: `@Machine`; docs `annot-machine`; LANGUAGE.md "A machine as data".
- Examples `actions/machine` (with `deer_steps.lres`); rejects for an unreachable state, no way out,
  an unknown action, an action with no row, a self-transition with no guard, an ambiguous trigger, a
  guard that writes, the field written by hand, `@Machine` off a registry and a field that is no
  enum. The `machine` block stays for a machine that is only code.
