bump: patch
type: fix
**`ludic.jobs`, `ludic.npc`: scopes and windows say what they hold.** A job's and a board's `scope` is `@OneOf(JOBS_SELF, JOBS_PARTY)` (the list also named the states and the group count, which are not scopes), so a game writes the package's own constants in its data instead of a registry of its own that an editor cannot match. `NpcStep.window` is `@OneOf(DAYW_)`, the way `JobDef.group` is `@OneOf(JG_)`: the game's windows, named by its prefix.
