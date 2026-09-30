# ludic.vitals

What an actor can lose and spend, as data. Pools (health, armour, stamina, a shield, poise, fuel) are rows
with a maximum, a regeneration and the delay before it starts; damage types, hit zones and each class of
actor's resistances are rows too; the pipeline (zone, resistance, what armour absorbs, then health) is the
package's. An actor's phase - alive, downed, dead, respawned - is a `@Machine` whose transitions are rows a
studio edits as a graph. The world (may this actor be hurt now, where does it stand) is asked through a
port, every outcome is a fact, and in a party the host's pools are the truth while a guest shows predicted
feedback. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.vitals"
```

The game fills four open registries, usually from resource files: `def VitalPools from "pools.lres"`,
`def DamageTypes`, `def HitZones`, `def VitalClasses`. Nothing here says what health or armour IS: a pool the
pipeline treats as life says `life: true`, one that takes damage before it says `absorb_order`. Amounts are the
game's units, times seconds. The package draws no dice (nothing in it is random), so there is no seed to keep.

No body is moved and no animation is played here. A class names the clips an animation layer plays
(`clip_down`, `clip_bleed`, `clip_death`, `clip_revive`, `clip_respawn`, `@Clip` against its `model`), and the
facts carry the one that goes with them (`VitalsFact.clip`); ludic.anim plays it.

## Data

```ludic
VitalPool   { key, name, icon, max, start, regen, regen_delay, regen_pct, delay_on_damage, delay_on_spend,
              regen_downed, absorb_order, absorb, overflow, life, predict, reconcile }
DamageType  { key, name, pierce, zoned }
HitZone     { key, name, mult, pierce, crit }
VitalClass  { key, name, pools, resists, zones, can_down, bleed_out, downed_hurt, revive_frac, revive_invuln,
              spawn_invuln, raise_dead, model, clip_down, clip_bleed, clip_death, clip_revive, clip_respawn }
ClassPool { pool, max, start, regen_mult, delay_mult }   ClassResist { type, mult }   ClassZone { zone, mult }
```

```
health  { life: true, max: 100.0, regen: 2.0, regen_delay: 6.0 }
armour  { absorb_order: 2, absorb: 0.6, max: 100.0 }
shield  { absorb_order: 1, absorb: 1.0, overflow: false, max: 40.0, regen: 10.0, regen_delay: 3.0 }
stamina { max: 100.0, regen: 20.0, regen_delay: 1.0, delay_on_spend: true, predict: true }
```

- **A pool** begins at `start` of `max` (and is respawned there), regenerates `regen` a second (negative drains,
  `regen_pct` makes it a share of the maximum) once `regen_delay` seconds have passed since its last hit
  (`delay_on_damage`) or spend (`delay_on_spend`). A step that ends the delay spends the rest of its time
  regenerating. `predict` marks a pool the owner's machine simulates (stamina, fuel) in a party.
- **A class** lists the pools it has (none listed: all of them) with a maximum, start and pace of its own
  (`ClassPool`), its resistances per damage type (`mult` 0 immune, 0.5 half, 1.5 weak) and per zone, and how it
  goes down: `can_down` falls and bleeds out for `bleed_out` seconds instead of dying, `downed_hurt` is the
  bleed-out seconds a point of damage costs while downed (0: it cannot be hurt; large: finished off),
  `raise_dead` lets a revive raise the dead.

## The damage pipeline

For `vitals_hurt(h, source, amount, type, zone, tag)`:

1. **Zone**: `amount x zone.mult x class zone mult` (only for a type that is `zoned`: a fall has no head). The
   zone's `crit` flag rides on the fact.
2. **Resistance**: `x class resist for the type x VitalsWorld.resist_mult(actor, type)` (a buff from
   ludic.effects). This is D.
3. **Pierce**: `pierce = clamp(type.pierce + zone.pierce, 0, 1)`. `D x pierce` goes straight to life.
4. **Absorption**: the rest, `R = D x (1 - pierce)`, walks the pools that have an `absorb_order`, lowest first. Each
   takes `R x absorb` (up to what it holds); what it cannot hold *overflows* to the next pool (`overflow: true`) or
   is lost (`overflow: false`, a shield that pops and swallows the blow); an empty pool passes everything. What
   is left of `R`, plus the pierced part, hurts the `life` pool.
5. **The end**: a pool that reaches 0 is a `VITALS_DEPLETED` fact; life at 0 downs (`can_down`) or kills the actor
   through the machine. A hit returns what it took from all pools; `vitals_preview_hurt` runs the same
   arithmetic and writes nothing.

Untouchable (a window from `vitals_invulnerable`, `spawn_invuln`, `revive_invuln`, or `VitalsWorld.can_be_hurt`
saying no) makes the hit a `VITALS_BLOCKED` fact and 0. Several hits in one frame that each empty life are one
death: the first marks the actor dying and the machine runs at the end of the phase.

## The machine

`@Machine(Vital.phase)` over `VitalPhase { Alive, Downed, Dead }`; the transitions are `steps.lres` in the package
(`VitalsSteps`, an open registry): `down` and `die` from Alive, `finish` and `bleed_out` (the tick's) from
Downed to Dead, `revive` from Downed, `raise` (when the class allows) and `respawn` from Dead. The verbs queue
the action, reduced at the end of the phase: call them in `PH_SIMULATE` and the state is settled before
`PH_RESOLVE` (a test calls `drain_actions()`). Respawning is the verb's: the wait, the place and the cost are
ludic.respawn's.

## Verbs

| | |
| --- | --- |
| `vitals_add(actor, class, persist) -> h`, `vitals_remove(h)`, `vitals_of(actor)`, `vitals_actor(h)`, `vitals_count()` | the actors; `persist` says a save keeps it |
| `vitals_hurt(h, source, amount, type, zone, tag) -> took`, `vitals_preview_hurt(h, amount, type, zone)` | a hit and its dry run; `tag` (a shot's id) is carried to the facts |
| `vitals_heal(h, amount)`, `vitals_restore(h, pool, amount) -> given`, `vitals_spend(h, pool, amount) -> bool`, `vitals_can_spend` | life, any pool back; spending is all or nothing |
| `vitals_set_max(h, pool, max, keep_share)`, `vitals_set(h, pool, value)` | upgrades and scripted scenes (host and solo) |
| `vitals_revive(h, by, frac) -> why`, `vitals_kill(h, source, type)`, `vitals_respawn(h)`, `vitals_invulnerable(h, seconds)` | the phase; -1 seconds is for good |
| `vitals_value`, `vitals_max`, `vitals_fraction`, `vitals_health`, `vitals_health_max`, `vitals_has_pool`, `vitals_life_pool`, `vitals_phase`, `vitals_alive`, `vitals_downed`, `vitals_dead`, `vitals_bleed_left`, `vitals_invuln_left`, `vitals_can_hurt`, `vitals_class`, `vitals_scaled` | what a bar or an AI asks |
| `vitals_reserve(n)` | room for n actors at once, made now (see Actors come and go) |
| `vitals_run(dt)`, `vitals_reset()`, `vitals_save()`, `vitals_load(v, version)`, `vitals_system()` | `"vitals"`, `PH_SIMULATE` |

## Actors come and go

A crowd spawns and despawns actors all game, so nothing is made per spawn. `vitals_remove` gives the actor's
record (and its three pool lists) back to a free list and `vitals_add` takes from it; a record is made only
when more actors are held at once than ever before, and then kept. A record that was downed or dead is
brought back to Alive by the machine's own `VitalsRecycle` (rows `recycle_downed`, `recycle_dead` in
steps.lres) before it is kept, so the phase is still only ever written by a transition.

Room is made ahead, before play: a state starts with `max_actors` records (the `VitalsSettings` row 0, a
`VitalsSetting { max_actors }` from a resource file; none: 128), and `vitals_reserve(n)` makes room for n
(records, table rows, the actor map) when a game wants more, for instance at a load. Past that a spawn is
still free once the new high water is reached, but a game that knows its busiest moment should size for it so
no frame ever makes a record.

Handles stay stable: a handle is a slot and a generation, and the slot's generation moves on at every
remove, so a stale handle misses (`vitals_actor(h)` is -1, `vitals_remove(h)` is false) and never reaches the
actor that now holds the record. `vitals_reset` returns every record to the free list too.

`why` is `VITALS_OK`, `_NO_SUCH`, `_NO_POOL`, `_NOT_ENOUGH`, `_WRONG_PHASE`, `_NOT_HOST` or `_REFUSED`.

## Facts

`vitals_facts() -> Queue<VitalsFact>`: `{ what, vital, actor, source, pool, type, zone, amount, absorbed, value,
crit, predicted, tag, clip, x, y, z }`:

| | |
| --- | --- |
| `VITALS_DAMAGED` | a hit took something: `amount` from all pools, `absorbed` by armour and shields, `value` life after |
| `VITALS_DOWNED`, `VITALS_DIED`, `VITALS_REVIVED`, `VITALS_RESPAWNED` | the machine's entries; `source` is the last to hurt it (the reviver for a revive), `clip` the class's, x y z where it fell (the port) |
| `VITALS_DEPLETED`, `VITALS_RESTORED` | a pool reached 0; a pool was given something back |
| `VITALS_BLOCKED`, `VITALS_INVULN_END` | a hit refused; a window closed |

## The ports

```ludic
export port VitalsWorld { can_be_hurt, resist_mult, x, y, z, allow_request }
```

Every member has a default: unbound, anyone may be hurt, nothing adds a resistance, actors stand at the origin, and
a guest's request is allowed only for its own actor or a revive.

## Binding the other mechanics: one line each

The functions below are in this package and take the vitals state like any system's; a port is a record of function
values, so nothing here names another package. Tested in `tests/adapters_test.ludic` against the real ones.

```ludic
bind MeleeDamage { hurt: fn vitals_melee_hurt }                   # a blow runs the pipeline; melee's type is the DamageTypes index
bind MeleeWorld { alive: fn vitals_actor_alive, can_afford: fn vitals_actor_can_spend, spend: fn vitals_actor_spend }   # stamina is a pool
bind AbilityResources { have: fn vitals_actor_have, spend: fn vitals_actor_spend, give: fn vitals_actor_give }   # mana, stamina, rage
bind AbilityEffects { damage: fn vitals_ability_damage, heal: fn vitals_ability_heal }
bind WeaponsDamage { hurt: fn vitals_weapon_hurt, alive: fn vitals_actor_standing }   # ludic.weapons: the zone reaches the pipeline
bind VitalsWorld { can_be_hurt: fn respawn_can_be_hurt }          # ludic.respawn's untouchable window
```

`ludic.respawn` also takes two routes in the game's resolve step, a line each: for a `VITALS_DIED` fact
`respawn_died(respawn_st, f.actor, vitals_death_cause(f), f.x, f.y, f.z)` (the cause is the damage type's key, the
name of a `RespawnRules` row) and for a `RESPAWN_RESPAWNED` fact `vitals_actor_respawn(vitals_st, r.who)`. A
resource in melee or abilities is the pool's index (`VPOOL_STAMINA`). The round that empties life counts as a
kill at once (`vitals_actor_standing` is false from then), before the machine runs.

## Multiplayer: the host decides

`vitals_set_role(VITALS_SOLO | VITALS_HOST | VITALS_GUEST)`. Solo and host simulate; their pools are the truth.
A guest holds a mirror:

- **Damage is the host's.** A guest cannot damage anyone: damage is worked out on the host from its own weapons,
  melee and collisions (the guest's *intent* - a shot - goes to ludic.weapons' host check). A guest's
  `vitals_hurt` changes nothing and returns the preview; it makes a `predicted: true` DAMAGED fact (same
  arithmetic, so the floating number is what the host will apply) for a hit marker and a sound. `tag` ties it to
  the act: when the host's own DAMAGED arrives for that `tag` the UI drops the guess.
- **State arrives as snapshots**: the host calls `vitals_snapshot(h, out)` (a kept `[]float`: seq, class, phase,
  bleed, untouchable time, value and maximum per pool) and sends it; a guest calls
  `vitals_apply_snapshot(actor, data, n)`, which makes the mirror if it is new, drops a stale one (older `seq`),
  and follows a phase change through the machine *silently* (no facts, no changes of its own).
- **Events arrive as relayed facts**: the host sends the facts it drains (they are plain numbers) and a guest shows
  them with `vitals_net_fact(...)`, which gives the clip from the class. Snapshots are state, facts are events; a
  machine shows each once.
- **A guest's other verbs are asks**: `vitals_heal`, `vitals_restore`, `vitals_spend` on a pool that is not its
  own, `vitals_revive`, `vitals_kill`, `vitals_respawn` dispatch the `@Net` action `VitalsAsk { who, kind, actor,
  pool, amount }`. It travels through the `NetActions` port the game binds to its session (ludic.net's
  `netact_*`), and the host checks it (`vitals_ask_ok`: the same answers `vitals_apply_request` gives, changing
  nothing) and reduces it with `vitals_apply_request(sender, kind, actor, pool, amount)`, where `sender` is the
  pid of the wire's slot (`action_sender()`, never a field of the message), and
  `VitalsWorld.allow_request(sender, kind, target)` decides (proximity to revive, say). `VitalsAsk` is
  `@Broadcast(none)`: pools go back out as snapshots. A refusal reaches the game through `NetActions.rejected`.
- **Predicted pools**: a pool marked `predict` of the actor this machine owns (`vitals_set_local(actor)`) is
  spent and restored here at once - a `@Predicted` row reducer of `VitalsAsk`, so the guess lands where the
  action is reduced (at the drain, as the phase verbs do) and `vitals_spend` / `vitals_restore` answer what it
  will do. The host's confirm keeps it; its refusal puts the actor's numbers and pool lists back as they were
  before the guess. A snapshot pulls it back only when the two differ by more than the pool's `reconcile`.

The package sends nothing: the game binds `NetActions` and puts the snapshot and the facts on its wire (ludic.net).

## Save

Section `vitals`, version 1: each persisting actor by the game's number with its class key, phase, bleed-out and
untouchable time left, and every pool's amount and maximum by the pool's key. A class or pool the file names and
the game no longer has is skipped; a pool the file lacks starts full.

## Tests

```bash
ludic test packages/ludic.vitals
```

`vitals_test`: the pipeline (zones, resistances, armour by fraction and order, overflow and a shield that pops,
pierce), regeneration after its delay, spending and maxima, the machine (down, bleed out, revive, raise, finish
off, respawn), untouchable windows, a guest's prediction, asks and snapshots, the host's checks, the save, and a
long run that makes nothing new. `adapters_test`: melee, abilities, weapons and respawn bound to vitals.

## Signals

The facts and values an animation graph (or a sound bank) can listen to, by name and without glue, are declared in `signals.ludic` as `SignalSources` (`ludic.base`): vitals.DAMAGED, vitals.DOWNED, vitals.DIED, vitals.health, and more. A game writes `AnimBindings` rows naming them (`ludic.anim`). They read the fact queue without draining it.
