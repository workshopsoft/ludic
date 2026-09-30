# ludic.loot

What drops: weighted loot tables that hold items or other tables, guaranteed lines and several
rolls, rarity tiers drawn by level and luck, affixes rolled for an item, and uniques that drop once.
Every draw is from the package's own dice, so a chest's contents can be fixed by a seed, and every
drop is a fact the game turns into a thing on the ground or in a pack. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.loot"
```

An item is the game's own number (`@Ref(Items)` names the registry an editor offers: it is the game's,
so the package reports it unresolved, which is a warning). A stat an affix changes is the game's
number too. The package knows what to DROP, never what an item is.

## Data

The game fills three open registries, usually from resource files: `def LootTables from
"loot.lres"`, `def LootRarities from "rarities.lres"`, `def LootAffixes from "affixes.lres"`.
Tables and affixes are `@ByKey` (the save names things by key); a rarity's number is its tier, so
rarities are `@AppendOnly`, plainest first. The package's own first rarity is `common` (index 0,
weight 100), so a game with no tiers still drops things.

```ludic
LootTable   { key, rolls_min, rolls_max, nothing, guaranteed: []LootEntry, entries: []LootEntry }
LootEntry   { item, table, weight, min_count, max_count, min_level, max_level, chance,
              rarity, min_rarity, affixes, tags, once, level_bonus }
LootRarity  { key, name, color, weight, luck_scale, min_level, roll, affix_min, affix_max, value_mult }
LootAffix   { key, name, slot, stat, lo, hi, per_level, weight, min_level, max_level, min_rarity,
              group, tags }
```

```
goblin {
  rolls_min: 1, rolls_max: 2, nothing: 20
  guaranteed: [{ item: ITM_BONES }]
  entries: [
    { item: ITM_COIN, weight: 50, min_count: 1, max_count: 5 }
    { item: ITM_SWORD, weight: 10, tags: ["weapon"], min_rarity: LRT_MAGIC }
    { table: LOOT_GEMS, weight: 5 }
  ]
}
```

- **A roll of a table**: each `guaranteed` line drops (with its own `chance`), then `rolls_min ..
  rolls_max` picks are made from `entries` by `weight`, `nothing` being a share that picks nothing.
- **A line is an item, another table, or (both -1) nothing.** A table line is rolled `min_count ..
  max_count` times, `level_bonus` levels higher. A table that holds itself, however deep, stops at
  `LOOT_DEPTH_MAX` (8) rather than never.
- **A level range** (`min_level`, `max_level`) gates a line; the world's `allowed(item, level)` may veto
  an item (a class's gear, a unique already owned).
- **`once: "name"`** drops at most once per game under that name, until `loot_once_release(name)`.
- **A tier** is the entry's own `rarity`, else drawn by weight among the tiers with `roll: true` whose
  `min_level` the level reaches, never plainer than the entry's `min_rarity`. Luck multiplies a
  tier's weight by `1 + luck * luck_scale`, so a rare tier grows faster than the plain one.
- **Affixes**: a tier carries `affix_min .. affix_max` of them; each is drawn by weight from those
  whose level range, `min_rarity` and `tags` fit the item (an affix with no tags goes on anything),
  one of a `group` per item. Its value is `lo .. hi` plus `per_level` for each level of the drop.

## The port

```ludic
export port LootWorld {
  luck: fn() -> float = ...              # magic find (unbound: 0)
  allowed: fn(int, int) -> bool = ...    # (item, level): may it drop (unbound: any)
}
```

## API

| | |
| --- | --- |
| `loot_roll(table, level, source) -> n`, `loot_roll_key(key, level, source)` | roll from the package's stream; `source` is the game's number for where it came from; n things dropped |
| `loot_roll_seeded(table, level, source, seed)` | the same from a stream of this seed, leaving the main stream where it was: a chest fixed by its number |
| `loot_seed(seed)`, `loot_find(key)` | the stream, and a table's number by key |
| `loot_odds_into(table, level, out) -> n` | what a roll is expected to give, per item (`LootOdds { item, expected }`), into the caller's own kept list: for tuning panels and tests |
| `loot_rarity_chances_into(level, luck, out)` | the chance of each tier at a level and luck |
| `loot_once_taken(name)`, `loot_once_release(name)`, `loot_rolls()`, `loot_drops()` | uniques and counts |
| `loot_facts() -> Queue<LootFact>` | `{ what, table, source, item, count, rarity, level, n_affix, affix, value }`: `LOOT_DROPPED` (one per item; `affix` and `value` are parallel) and `LOOT_EMPTY` (a roll gave nothing) |
| `loot_reset()`, `loot_save()`, `loot_load(v, version)`, `loot_system()` | `"loot"`, `PH_COMMIT`, no tick; saved: the dice, the uniques, the counts |

A fact's record (and its lists) is reused after the next drain: read it, never keep it.

## Tests

```bash
ludic test packages/ludic.loot
```
