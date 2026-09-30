# ludic.melee

Attacks as data played on animation clips: hit windows (when on the clip) and hit shapes (arc, box or
sphere in front of the attacker), combos by input window, blocking and parrying, poise and stagger.
A fighter's phase is a `@Machine` whose transitions are rows a studio edits as a graph. Every swing,
hit and stagger is a fact; damage goes through a port to the game's health. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.melee"
```

The game fills two open registries, usually from resource files: `def MeleeAttacks from
"attacks.lres"`, `def MeleeSets from "melee_sets.lres"`. A clip is the game's animation (ludic.anim
plays it; melee only names it and asks its length); a damage type and a stamina resource are the
game's own numbers. Times are seconds on the attack's clip, lengths metres, angles degrees, and a yaw
of 0 faces +z (forward is `(sin yaw, cos yaw)` on `(x, z)`).

## Data

```ludic
MeleeAttack { key, name, clip, length, speed, cost, hits, light, heavy, chain_start, chain_end,
              guard_from, armor, move_mult, turn_mult }
MeleeHit    { key, start, stop, shape, reach, arc, length, width, radius, fwd, side, up, height,
              damage, damage_type, stagger, knockback, rehit, blockable, parryable }
MeleeSet    { key, name, light, heavy, cost_resource, poise, poise_regen, poise_delay, stagger_time,
              buffer, block_arc, block_mult, block_poise, block_move, parry_window, parry_stagger }
```

```
slash1 {
  clip: "slash1", length: 1.0, cost: 10.0, light: MAT_SLASH2, heavy: MAT_SMASH
  chain_start: 0.5, chain_end: 0.9, guard_from: 0.7
  hits: [{ start: 0.2, stop: 0.4, shape: MELEE_SHAPE_ARC, reach: 2.0, arc: 90.0, damage: 10.0, stagger: 15.0 }]
}
```

- **A hit window** is open while the clip is between `start` and `stop` (a step that jumps the whole
  window still crosses it). It reaches anyone the world finds near, inside its shape: `MELEE_SHAPE_ARC`
  (a sector, `reach` and `arc`), `_BOX` (from `fwd` for `length`, `width` across, `side` off centre) or
  `_SPHERE` (`radius` at `side`, `up`, `fwd`); arcs and boxes are `height` tall from `up`. The body's own
  radius widens every test. A swing hits a body once per window, or again every `rehit` seconds.
  `melee_shape_hits(...)` is the pure test, for an editor's gizmo or a check.
- **A combo**: a press inside `chain_start .. chain_end` of an attack goes to its `light` or `heavy`
  link. A press before the window is kept for the set's `buffer` (and for as long as the window is
  still ahead) and used the moment it opens; one a moment after a swing ends starts the set's first
  attack. `length: 0` asks the clip's own length through the port.
- **Guard and parry**: a raised guard covers `block_arc` degrees in front. A blow through it lets
  `block_mult` of its damage by and costs `block_poise` of its stagger in stamina; a guard that cannot
  pay is broken and staggered. In the first `parry_window` seconds of a guard a blow is turned aside
  instead: no damage, and the attacker is staggered `parry_stagger` seconds. `blockable: false` and
  `parryable: false` exempt a window. A swing may be dropped into a guard from `guard_from`.
- **Poise**: each hit takes its `stagger` from the victim's poise (less the `armor` of a swing the
  victim is playing); at 0 the victim is staggered `stagger_time` and its poise refills. Poise comes
  back at `poise_regen` a second after `poise_delay` without a hit.

## The machine

`@Machine(Fighter.phase)` over `MeleePhase { Ready, Attack, Block, Stagger }`. The transitions are
`steps.lres` in the package (`MeleeSteps`, an open registry); the compiler turns them into reducers
for the actions `MeleeAttackIn`, `MeleeBlockIn`, `MeleeUnblockIn`, `MeleeStaggerIn`, `MeleeCancelIn` and
into `melee_steps_tick` for the rows the tick asks (a swing played out, a chain, a stagger worn off, a
buffered press). **The verbs queue the action, which is reduced at the end of the phase**: call them in
`PH_INPUT` and the state is settled before `PH_SIMULATE` (a test calls `drain_actions()`).

## The ports

Every member has a default: unbound, actors stand at the origin facing +z with a 0.4 m body, everyone
but oneself is an enemy, stamina is no object, a hit does nothing (the facts still say it landed) and
a clip's length is the attack's own.

```ludic
export port MeleeWorld { x, y, z, yaw, radius, height, alive, hostile, find, can_afford, spend,
                         power, attack_speed, crit_chance, crit_mult, clip_length, play }
export port MeleeDamage { hurt: fn(victim, attacker, amount, type) -> float, push: fn(victim, attacker, force) -> void }
```

`find(x, z, radius, out)` pushes the actors in a circle into `out`; `play(actor, clip, speed)` tells the
game's animation to start; `hurt` returns what the victim actually took (armour, resistances).

## API

| | |
| --- | --- |
| `melee_add(actor, set, persist) -> h`, `melee_remove(h)`, `melee_fighter_of(actor)`, `melee_actor(h)`, `melee_equip(h, set)`, `melee_fighter_count()` | the fighters |
| `melee_attack(h, kind) -> why`, `melee_guard_up(h)`, `melee_guard_down(h)`, `melee_cancel(h)`, `melee_stagger(h, seconds)`, `melee_set_poise(h, poise)` | what a player or an AI does; `kind` is `MELEE_LIGHT` or `MELEE_HEAVY`; why is `MELEE_OK`, `_NO_SUCH`, `_NO_ATTACK`, `_TOO_TIRED`, `_STAGGERED_NOW` or `_NO_CHAIN` (also a `MELEE_REFUSED` fact) |
| `melee_phase(h)`, `melee_attacking(h)`, `melee_blocking(h)`, `melee_staggered(h)`, `melee_attack_of(h)`, `melee_time(h)`, `melee_progress(h)`, `melee_combo(h)`, `melee_poise(h)`, `melee_stun(h)`, `melee_queued(h)`, `melee_chain_open(h)`, `melee_window_open(h)`, `melee_length(attack)` | what the game reads |
| `melee_move_mult(h)`, `melee_turn_mult(h)` | how much of its walking and turning a fighter keeps now |
| `melee_shape_hits(hit, ax, ay, az, yaw, vx, vy, vz, vr, vh)`, `melee_hit_bound(hit)` | the shape test, and how far a shape reaches |
| `melee_seed(seed)`, `melee_run(dt)` | the dice (crits); one step |
| `melee_facts() -> Queue<MeleeFact>` | `{ what, fighter, actor, victim, attack, hit, combo, result, why, damage, stagger, crit, time }`: `MELEE_SWING`, `_HIT` (result `MELEE_RESULT_HIT`, `_BLOCKED`, `_PARRIED`, `_GUARD_BROKEN`), `_ENDED`, `_STAGGERED`, `_RECOVERED`, `_POISE_BROKEN`, `_GUARD_UP`, `_GUARD_DOWN`, `_REFUSED` |
| `melee_reset()`, `melee_save()`, `melee_load(v, version)`, `melee_system()` | `"melee"`, `PH_SIMULATE`; saved: the dice, and each persisting fighter's actor and moveset key (a swing in progress is not saved) |

## Tests

```bash
ludic test packages/ludic.melee
```

## Signals

The facts and values an animation graph (or a sound bank) can listen to, by name and without glue, are declared in `signals.ludic` as `SignalSources` (`ludic.base`): melee.SWING, melee.HIT_TAKEN, melee.attacking, and more. A game writes `AnimBindings` rows naming them (`ludic.anim`). They read the fact queue without draining it.
