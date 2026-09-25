# ludic.effects

Timed modifiers that run down in game time: a meal that holds the cold off for fifty minutes, a
drink that is twenty minutes of legs and then a crash, a soaking that chills you for ten. The
rules of the game ask one question - "what should I add for this kind right now?" - and the
package answers it. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.effects"
```

A kind is the game's own number (`EF_WARMTH_RATE`, `EF_CARRY`, ...); the package never knows what
one means. A magnitude is in that kind's units. Time is game minutes.

## Rules

- **The same kind from the same label replaces itself.** A second soda extends the fizz, it does
  not double it.
- **Bonuses are capped** (`effects_config(max, bonus_max)`, 8 and 3 by default): a bonus that would
  be one too many pushes out the bonus nearest its end. A menu is a choice.
- **A full ring** drops whatever is nearest its end.
- **A delayed effect** (`effects_add_after`) counts for nothing until it begins, then runs its time.

## API

| | |
| --- | --- |
| `effects_add(kind, mag, minutes, bonus, label)` | start one now |
| `effects_add_after(after, kind, mag, minutes, bonus, label)` | start one `after` game minutes from now |
| `effects_clear()` | stop everything, silently (a new trip, a night's sleep) |
| `effects_run(minutes)` | run them down (the system's tick does this from `Tick.hours`) |
| `effects_sum(kind)`, `effects_has(kind)`, `effects_bonus_count()` | what the rules ask |
| `effects_count()`, `effects_at(i) -> Effect`, `effects_live() -> []int` | what a read-out draws (`effects_at` is a copy) |
| `effects_config(max, bonus_max)`, `effects_capacity()`, `effects_bonus_capacity()` | the ring's size |
| `effects_ended() -> Queue<EffectEnded>` | the facts: `{ kind, label, why, bonus }`, `why` one of `EFFECT_RAN_OUT`, `EFFECT_PUSHED_OUT`, `EFFECT_CROWDED_OUT` |
| `effects_system() -> System` | `"effects"`, `PH_SIMULATE`: reset, tick, and its save section (`effects_save`, `effects_load`) |

No ports: the package asks the world nothing.

## Tests

```bash
ludic build packages/ludic.effects/tests/effects_test.ludic --headless -o /tmp/effects_test && /tmp/effects_test
```
