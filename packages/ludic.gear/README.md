# ludic.gear

Tiers of kit bought one at a time with money once a vendor knows you, the numbers each tier is
worth, what is in the hand, and the charges that burn down while in use - a torch's flame, a
battery. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.gear"
```

The game fills three open registries, usually from resource files: `def GearKinds from
"gear.lres"`, `def GearValues from "gear_values.lres"`, `def GearCharges from "gear_charges.lres"`.
A kind's names, blurbs and vendor, and what running out of a charge means, are the game's.

## The rules it keeps

1. **A tier is bought flat.** `gear_buy(k)` wants the next tier's `rep` in `GearPurse.rep()` and its
   `cost` in `GearPurse.money()`, spends it through `GearPurse.spend`, and says `GEAR_BOUGHT`.
   Nothing about a tier's price moves with a shop's curve or its week.
2. **The kind's item follows, and an item carried counts.** A kind with an `item` puts one in the
   pack when bought and none is there, and `gear_sync()` (after every load) lifts a kind to its
   first tier when the pack already carries the item.
3. **A tier decides numbers by table.** `gear_value(v)` is `GearValues[v].at[level]`, the last entry
   holding past the end; `gear_mult(k)` is the kind's own `mult` the same way (1.0 when it has
   none). `gear_stack_limit(base, mult)` keeps a single thing single and never scales a stack to
   nothing.
4. **A charge burns only while it runs, by game hours.** A `hand` charge runs only while its item
   is held, and a new thing in the hand puts it out. One that reaches zero stops and says
   `GEAR_RAN_OUT`; replacing a burnt torch is the game's.

## The ports

```ludic
export port GearPurse { money: fn() -> int, spend: fn(int) -> bool, rep: fn() -> int }   # required
export port GearPack { count: fn(int) -> int, add: fn(int, int) -> int }   # unbound: empty, takes nothing
export port GearWorld { hidden: fn(int) -> bool }                          # unbound: every kind on sale
```

## API

| | |
| --- | --- |
| `GearKind { key, vendor, icon, tiers, blurb, howto, names, cost, rep, item, start, mult }`, `open registry GearKinds ... as GEAR` | a kind: per tier to buy, `names` / `cost` / `rep`; `start` the level a trip begins at |
| `GearValue { key, gear, at }`, `open registry GearValues ... as GV` | a number a kind's tier decides, per level from 0 |
| `GearCharge { key, item, full, per_hour, rate, low, hand }`, `open registry GearCharges ... as CHARGE` | a charge; `rate` a value's index to burn by instead of `per_hour`; `low` the level a hint calls it nearly out |
| `gear_level(k)`, `gear_set_level(k, lv)`, `gear_owned(k)`, `gear_best(k)`, `gear_level_name(k, lv)` | what is owned |
| `gear_next_name(k)`, `gear_next_cost(k)`, `gear_next_rep(k)`, `gear_can_buy(k)`, `gear_buy(k)`, `gear_kinds_at(vendor)`, `gear_sync()` | buying |
| `gear_mult(k)`, `gear_value(v)`, `gear_stack_limit(base, mult)` | what a tier is worth |
| `gear_hand()`, `gear_set_hand(it)`, `gear_lit()` | the hand |
| `gear_charge_of(it)`, `gear_charge(c)`, `gear_charge_set(c, v)`, `gear_charge_fill(c)`, `gear_running(c)`, `gear_run(c, on)` | the charges |
| `gear_facts() -> Queue<GearFact>` | `{ what: GEAR_BOUGHT / GEAR_RAN_OUT, kind, level, cost, charge, item }` |
| `gear_reset()`, `gear_save()`, `gear_load(v, version)`, `gear_system()` | `"gear"`, `PH_SIMULATE`: the burn each tick; the levels and charges saved by key (the hand is not) |

## Tests

```bash
ludic test packages/ludic.gear
```
