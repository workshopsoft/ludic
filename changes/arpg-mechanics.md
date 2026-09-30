bump: minor
type: feat
**Four action-RPG mechanic packages**, each depending on `ludic.base` only and driven by data.

- **`ludic.abilities`** — abilities, spells and skills as data: cost through a resource port, cast time, cooldowns, groups and charges, targeting, effect chains applied through ports, channels, learnable levels and a hotbar.
- **`ludic.melee`** — attacks as data on animation clips: hit windows and shapes, combos by input window, blocking and parrying, poise and stagger; a fighter's phase is a `@Machine`, damage goes through a port.
- **`ludic.loot`** — weighted loot tables (nested, guaranteed, rolls), rarity tiers by level and luck, affixes, uniques dropped once, seeded rolls, drops as facts.
- **`ludic.travel`** — waypoints a player discovers and fast-travels between: unlock rules, cost in coins and hours, the load through a port, map markers as data.
