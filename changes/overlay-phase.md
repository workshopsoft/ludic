bump: minor
type: feat
`Overlay` render phase — runs after the engine Render systems (sprites, lights) and before present, so a game's HUD / menus are never painted under an actor. Byte-identical when unused.
