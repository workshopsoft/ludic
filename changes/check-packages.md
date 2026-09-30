bump: patch
type: feat
**`ludic-dev check-packages`: every first-party package in one program.** Registry prefixes and exported names are global, so packages that compile alone can clash in a game. The task imports every importable package into one program, binds nothing and runs `ludicc --check`; a declaration error (`defined twice`, an unknown `@Unit`, ...) fails it and names the packages involved. Only `port X is used here but never bound` and the `@Ref` "this program has no X" warnings are expected. CI runs it. `docs/PACKAGES.md` gains the naming rule for prefixes and exports.

`@Unit` accepts `ms` (milliseconds) and `1/h` (a rate per hour); `ludic.lobby`'s `ping_max` fields have their `@Unit("ms")` back.
