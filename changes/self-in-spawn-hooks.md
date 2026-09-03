bump: patch
type: fix
`self()` inside an `@OnSpawn(Model)` or `@OnAttach(Property)` body is now the entity being constructed. Previously it was the entity of the innermost query loop — or the constant 0 when the spawn happened outside any loop — so a hook such as `@OnSpawn(Hero) handler Remember { player = self() }` silently recorded entity 0.
