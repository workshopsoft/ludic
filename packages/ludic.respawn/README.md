# ludic.respawn

Death to respawn as rules: the points a map holds, a rule per cause of death (where it puts the subject,
what it costs, how long the wait, how long the subject is untouchable after), each subject's own
checkpoint, and a fact for every step. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.respawn"
```

The package takes nothing from a wallet and moves no body. A `RESPAWN_RESPAWNED` fact says where the
subject goes, what to take from it (`charged`) and the share of what it carries to lose (`lose`); the game
does those.

## The data

**Points are per map** - a `@PerMap` table the editor places, `maps/<map>/respawn.lres`, loaded with
`respawn_points_load(points, map)` (the compiler writes that state and its verbs):

```
clinic { x: 10.0, y: 0.0, z: 5.0, kind: "hospital" }
cp1    { x: 100.0, z: 0.0, kind: "checkpoint", reach: 10.0 }       # passing within 10 m makes it the checkpoint
vip    { x: 210.0, z: 0.0, kind: "hospital", locked: true }        # offered only after respawn_unlock
```

`kind` is one of `checkpoint`, `hospital`, `home`, `start` (an `@OneOf`); `yaw` faces the subject.

**Rules are a game table**, `RespawnRules` (open, append-only, `RSPR_*`), keyed by the cause the game passes
to `respawn_died`:

```
wasted { mode: "nearest", kind: "hospital", cost: 100.0, cost_pct: 0.1, cost_max: 500.0, free: 1, lose: 0.25, delay: 4.0, invuln: 5.0 }
fell   { mode: "checkpoint", delay: 0.0, invuln: 2.0 }
```

`mode`: the subject's last `checkpoint` (none made: the nearest point), the `nearest` point of `kind` ("" any),
the nearest `home`, or the map's `start`. Cost: the first `free` deaths cost nothing; after that `cost` plus
`cost_pct` of what the subject has (`RespawnWorld.funds`), at most `cost_max` (0 no most), never more than it
has. A cause no row names uses a built-in rule (nearest of any kind, free, 3 s wait, 3 s untouchable).

A point the world calls unsafe (`RespawnWorld.safe(x, y, z)`) is passed over for the next nearest, up to eight
tries; if all are unsafe the first stands. A map with no point at all puts the subject back where it fell
(`RESPAWN_NOWHERE`).

## Verbs

| | |
| --- | --- |
| `respawn_died(who, cause, x, y, z) -> bool` | dead; false if already dead. Put back after the rule's delay |
| `respawn_now(points, who)`, `respawn_revive(who)` | skip the wait; alive with no respawn |
| `respawn_checkpoint(points, who, key)`, `respawn_visit(points, who, x, z)`, `respawn_clear_checkpoint` | a checkpoint by key, or by passing within `reach` |
| `respawn_unlock(points, who, key)` | open a `locked` point for one subject |
| `respawn_alive / _dead / _invulnerable / _can_be_hurt / _invuln_left / _wait_left / _deaths / _checkpoint_key` | the questions; `respawn_can_be_hurt` is the game's damage check |
| `respawn_nearest_point(points, kind, x, z)` | an index, for a map's "go to the nearest hospital" |
| `respawn_tick`, `respawn_reset`, `respawn_save`, `respawn_load`, `respawn_system()` | the system (`PH_SIMULATE`) |

Port: `RespawnWorld { funds(who) -> float, safe(x, y, z) -> bool }`, both defaulted (rich enough, safe).

## Facts

`respawn_facts()`: `RESPAWN_DIED`, `RESPAWN_RESPAWNED` (point, position, yaw, charged, lose, invuln),
`RESPAWN_INVULN_END`, `RESPAWN_CHECKPOINT`, `RESPAWN_UNLOCKED`, `RESPAWN_NOWHERE`.

## Save

Section `respawn`, version 1: each subject's deaths, checkpoint key, the keys it has unlocked, the untouchable
time left, and a death still waiting (put back on the first tick after a load).

## Tests

`ludic test packages/ludic.respawn`, against the map in `tests/maps/town`.
