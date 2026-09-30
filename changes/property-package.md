bump: minor
type: feat
**`ludic.property`: housing and businesses.** A package on `ludic.base` alone; money, interior loading, items and vehicles are ports.

- **Registries** - `PropertyKinds` (an interior map and further maps of a multi-map interior, garage, storage and upgrade slots, rentable, raidable), `Properties` (`@PerMap` entrances with price, rent and district), `PropertyUpgrades`, and `BusinessLoops`.
- **Ownership per player** (`realty_buy`, `_sell`, `_rent`, `_trade`, `_upgrade`) through a purse port, rent a game day at a time with a grace period and taking back, access lists (owner, invited, crew, friends, public).
- **Instanced interiors**: `realty_enter` gives each visit an instance id (the live one is joined), the game loads the map through `RealtyLoad`, `realty_go_floor` moves between the maps of one interior, the last one out closes it.
- **Storage** of items and vehicles through ports, raids with a cooldown, passive income, upkeep.
- **Business loops as a `@Machine`** (`steps.lres`): supply, produce on a timer, full, a timed sale run that pays.
- **Host-authoritative**: verbs refuse on a guest (`REALTY_NOT_HOST`); `realty_snapshot` / `realty_apply_snapshot` replicate; facts for every change; a save section by key.
