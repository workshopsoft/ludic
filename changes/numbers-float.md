bump: minor
type: feat
**`numbers float` — a module whose decimal literals are `float`.** A bare `1.5` is `fixed`
unless a float is in sight, which is the right default for deterministic code and the wrong
one for a renderer or a game whose numbers are all IEEE: `Math.sqrt(2.0)` came out in `fixed`,
and every literal needed a `float(...)` round it. A file that says `numbers float` (at the top,
or inside a `program` block) gets float literals, and passes the mode on to every non-runtime
file it imports, so one line in a barrel or an entry file covers a whole package. Runtime files
under `runtime/` are never switched, so the engine's own fixed-point code keeps its meaning.
