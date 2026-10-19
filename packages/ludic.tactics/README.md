# ludic.tactics

The thinking of a shooter's enemies, without a body: the game moves the figures, fires the guns and answers the world through the
`TacticsWorld` port (`ray(a, b)`: the fraction before something blocks, or -1; `ground(x, y_hint, z)`: the walkable height or
`TAC_NO_GROUND`). Uses ludic.base and nothing else. Pure functions over records the game owns, so a test holds every rule.

| File | What |
| --- | --- |
| `defs.ludic` | alert states `TAC_*`, actions `TACT_*`, callouts `TAC_CALL_*`, loudness `TAC_LOUD_*`, `TacArchetype` (a row of the game's), the port, a hash |
| `perception.ludic` | `TacPerceiver`: `tac_sight` (cone, range, light, stance), `tac_perceive` (the awareness meter, memory, unaware / suspicious / alert / combat / searching, giving up), `tac_hear`, `tac_tell`, `tac_shot_at` |
| `cover.ludic` | `TacCover`: `tac_cover_generate` (rays at knee, chest and eye height in 16 directions: low and high cover, the side a high one is peeked round), `tac_cover_pick` with a `TacQuery` (cover, advance, flank, retreat), `tac_cover_protects`, `tac_cover_fires`, `tac_cover_take / _release` |
| `decide.ludic` | `TacMorale` (hits, allies down, near misses, recovery), `TacCtx` + `tac_choose` (the utility scorer with commitment), `tac_aim_miss` and `tac_aim_dir` (seeded misses that grow with distance, movement and suppression and shrink as the aim settles) |
| `squad.ludic` | `TacSquad`: the shared contact, one flanker at a time, callouts with cooldowns and their text |

`ludic test packages/ludic.tactics/tests` runs the rules on a world of boxes.
