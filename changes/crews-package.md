bump: minor
type: feat
**`ludic.crews`: gangs and crews.** A package on `ludic.base` alone; membership, money and player positions come through ports.

- **Registries** - `CrewRanks` (power and permissions), `CrewRelations` (ally, neutral, rival, war as rules: contest, friendly fire, mutual, kill and bounty shares, hold time, escalation by kills), `CrewSettings`, `CrewSources`, `CrewEmblems`, and `Territories` (`@PerMap` discs, polygons or grid cells with value and income).
- **Crews**: create, invite, join, leave, kick, promote, transfer, a bank with a daily limit per rank, emblem and colours, disband.
- **Influence** per crew per territory from kills, presence and reported jobs, with decay and a cap; bounties; rivalries that harden by themselves.
- **Turf war as a `@Machine`** (`steps.lres`): peace, contested, war (declared or escalated, scored by kills), captured or held, cooldown; territories pay income into the owner's bank.
- **Host-authoritative**: verbs refuse on a guest (`CREW_NOT_HOST`); `crew_snapshot` / `crew_apply_snapshot`; facts for every change; a save section by key.
