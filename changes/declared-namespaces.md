bump: minor
type: feature
**Namespaces are declared in Ludic.** `alias meth(labels) = target` in a `namespace` block makes
`Ns.meth(...)` a call to `target`, taking named arguments by those labels; with no label list the
target's own parameter names are the labels. The engine's 41 table-driven namespaces - `Http`,
`Udp`, `Process`, `Json`, `Value`, `Screen`, `Input`, `Audio`, `World`, `Tiled` and the rest, 438
methods - moved out of the compiler into `runtime/native/namespaces.ludic`, and a package owns an
API the same way. The code a program compiles to is unchanged byte for byte, and the checker now
checks an alias call's arguments against its target.
