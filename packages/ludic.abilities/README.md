# ludic.abilities

Abilities, spells and skills as data: what they cost (through a resource port), how long they take
to cast, their cooldown and stored charges, how they are aimed (self, a point, a direction, a
target, an area), a chain of effects applied through ports, channelled ones that pulse, levels a
caster learns with points, and a hotbar. Uses [`ludic.base`](../ludic.base/README.md) and nothing
else.

```ludic
import "ludic.abilities"
```

The game fills one open registry, usually from a resource file: `def Abilities from
"abilities.lres"`. A resource (mana, stamina, health), a stat, a damage type and an effect kind are
the game's own numbers: the package carries them from a row to a port and never knows what they
mean. The actors that cast are rows the game adds (`abilities_add_caster(actor, persist)`), found
again by the game's number for the actor.

## Data

```ludic
Ability { key, name, blurb, icon, kind, target, range, radius, at_caster, cast_time, cooldown, gcd,
          on_gcd, group, charges, recharge, channel, channel_tick, cost_at, cost, refund,
          interruptible, move_cancels, clip, effects, levels, learn_cost, req_level, level_step,
          requires, requires_level }
AbilityCost   { resource, amount, per_level }
AbilityEffect { kind, to, stat, magnitude, per_level, scale_stat, scale, duration, delay, chance,
                variance, crit, bonus, label }
```

```
fireball {
  target: AB_TARGET_POINT, range: 30.0, radius: 4.0, cast_time: 1.0, cooldown: 6.0, levels: 3
  cost: [{ resource: RES_MANA, amount: 20.0, per_level: 5.0 }]
  effects: [
    { kind: AB_FX_DAMAGE, to: AB_TO_ENEMIES, stat: DMG_FIRE, magnitude: 30.0, per_level: 10.0, scale_stat: STAT_INT, scale: 0.5 }
    { kind: AB_FX_APPLY, to: AB_TO_ENEMIES, stat: EF_BURN, magnitude: 3.0, duration: 4.0, delay: 0.5, label: "burn" }
  ]
}
```

- **Targeting**: `AB_TARGET_SELF`, `_POINT` (`range` from the caster), `_DIRECTION` (the two numbers
  are a heading), `_TARGET` (an actor the game chose, checked by the world and `range`), `_AREA`
  (`radius` round the point, or round the caster with `at_caster`).
- **A chain** of effects runs when the cast resolves (every pulse of a channel). Each link has a kind
  (`AB_FX_DAMAGE`, `_HEAL`, `_APPLY` a timed effect, `_RESTORE` a resource, `_DISPEL`, `_PUSH`, `_SPAWN`
  a fact for the game to make a bolt or a minion), a `to` (`AB_TO_SELF`, `_TARGET`, `_ENEMIES`,
  `_ALLIES`, `_ALL`; the last three through the area `radius` and the world's `allied`), a `delay` in
  seconds, a `chance`, and a number: `magnitude + per_level * (level - 1) + scale * the caster's stat`,
  varied by `variance`, doubled by a crit when `crit` and the world's `crit_chance` say so.
- **Costs** are paid at the start of a cast (`cost_at: AB_COST_START`) or at its end; an interrupted
  cast gives its cost back when `refund`. A channelled ability pays its cost on every pulse instead,
  and ends when it cannot.
- **Cooldowns**: its own `cooldown` (times the world's `cooldown_mult`), shared across a `group`; `gcd`
  is a pause the caster carries, which abilities with `on_gcd` wait for. `charges` are stored uses that
  come back one per `recharge` seconds.
- **Levels**: `levels` the most, `learn_cost` points a level, the caster's own level `req_level +
  level_step * level`, and `requires` (abilities known to `requires_level`). A passive
  (`AB_KIND_PASSIVE`) is levelled and never cast: the game reads `abilities_level`.
- **Hotbar**: `AB_SLOTS` (12) places of known abilities.

## The ports

Every member has a default, so any may be left out: unbound, everything costs nothing, every actor is
at the origin on level 1 with no stats, anyone may cast at anyone, nobody is allied or in any circle,
and a hit does nothing (the facts still say it landed).

```ludic
export port AbilityResources { have: fn(int, int) -> float, spend: fn(int, int, float) -> bool, give: fn(int, int, float) -> void }
export port AbilityEffects { damage, heal, apply, dispel, push }       # apply: bind it to ludic.effects' effects_add
export port AbilityWorld { x, z, level, stat, can_cast, valid_target, allied, find, crit_chance,
                           crit_mult, cast_speed, cooldown_mult, points, spend_points, give_points }
```

`find(x, z, radius, out)` pushes the actors in a circle into `out` (the package's own kept list) and
returns how many.

## API

| | |
| --- | --- |
| `abilities_add_caster(actor, persist) -> h`, `abilities_remove_caster(h)`, `abilities_caster_of(actor)`, `abilities_actor(h)`, `abilities_caster_count()` | the casters; `persist` says a save keeps it (the player's, not a monster's) |
| `abilities_learn(h, a) -> why`, `abilities_can_learn(h, a)`, `abilities_grant(h, a, level)`, `abilities_forget(h, a)`, `abilities_respec(h)`, `abilities_level(h, a)`, `abilities_knows(h, a)`, `abilities_req_level(h, a)` | levels and points |
| `abilities_bind(h, slot, a)`, `abilities_unbind(h, slot)`, `abilities_slot(h, slot)`, `abilities_use_slot(h, slot, tx, tz, target)` | the hotbar |
| `abilities_cast(h, a, tx, tz, target) -> why`, `abilities_why_not(...)`, `abilities_can_cast(...)` | a cast: `AB_OK`, or `AB_NO_SUCH`, `_NOT_KNOWN`, `_PASSIVE`, `_BUSY`, `_COOLING`, `_NO_CHARGES`, `_GCD`, `_CANT`, `_NEEDS_TARGET`, `_BAD_TARGET`, `_OUT_OF_RANGE`, `_NO_RESOURCE` |
| `abilities_interrupt(h, why)`, `abilities_stop(h)`, `abilities_hurt(h)`, `abilities_moved(h)` | lose a cast or channel: any, on purpose, by a blow (if `interruptible`), by walking (if `move_cancels`) |
| `abilities_phase(h)`, `abilities_active(h)`, `abilities_progress(h)`, `abilities_cooldown(h, a)`, `abilities_charges(h, a)`, `abilities_gcd(h)`, `abilities_cost_amount(a, i, level)`, `abilities_pending_count()` | what a bar draws |
| `abilities_find(key)` | the registry's own lookup, generated by the compiler |
| `abilities_seed(seed)`, `abilities_run(dt)` | the dice (variance, chance, crit); one step |
| `abilities_facts() -> Queue<AbilityFact>` | `{ what, caster, actor, ability, level, target, why, x, z, kind, amount }`: `AB_CAST_STARTED`, `_CAST_DONE`, `_INTERRUPTED`, `_REFUSED`, `_CHANNEL_TICK`, `_CHANNEL_END`, `_EFFECT` (a number to float over a head), `_SPAWN`, `_READY`, `_CHARGE`, `_LEARNED`, `_FORGOTTEN` |
| `abilities_reset()`, `abilities_save()`, `abilities_load(v, version)`, `abilities_system()` | `"abilities"`, `PH_SIMULATE`; saved: each persisting caster by actor, with levels, hotbar, cooldowns and charges by key (handles are not saved: ask `abilities_caster_of`) |

## Tests

```bash
ludic test packages/ludic.abilities
```
