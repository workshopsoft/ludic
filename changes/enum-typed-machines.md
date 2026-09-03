bump: minor
type: feat
A `machine` over an enum-typed store maps its states to the enum by name: with `enum HeroState { Idle, Rolling }` and `var hero_state: HeroState = HeroState.Idle`, `machine hero_state { state Idle { … } state Rolling { … } }` dispatches on `HeroState.Idle` / `HeroState.Rolling` — no `state Idle = HeroState.Idle` repetition, and a state that names no variant is a compile error. A bare enum is now a first-class `int`-sized type for `var`, params, fields and returns (`llty`), and `Enum.Variant` folds in a global initializer.
