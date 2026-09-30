# ludic.wanted

Heat against a subject - a player, a faction, a gang: crimes raise it by their weights, time out of
sight sheds it, its levels and the responses each level calls for are rows the game fills, and the
phase a subject is in (Clear, Wanted, Searching) is a machine whose graph is a table. The package
keeps the numbers and says what happened; the game's AI reads the facts and sends the police. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.wanted"
```

The package never spawns, draws or words anything. It does not know what a "patrol" is: a response's
`what` is the game's own word, handed back in a fact.

## The data

Three open, append-only registries (`def` them in code or bring a file with `def WantedLevels from
"levels.lres"`):

```
# levels.lres - the level a heat reaches is its row's place + 1; 0 is clear
one   { heat: 10.0, lose: 6.0,  decay: 2.0 }      # out of sight 6 s and the search begins; a search sheds 2 heat a second
two   { heat: 30.0, lose: 10.0, decay: 3.0 }
three { heat: 60.0, lose: 15.0, decay: 4.0 }
```

- **`WantedLevels`** (`WANTL_*`): `heat` reaches it, `lose` seconds out of sight before the search,
  `decay` heat a second shed while searching (and while clear).
- **`WantedCrimes`** (`WANTC_*`): `heat` added; `witness` (it counts only if the world says somebody saw
  it; a witnessed crime is a sighting too); `repeat_gap` and `repeat` (the same crime by the same subject
  again within the gap adds only that share: a string of smashed windows is not a string of murders);
  `cap` (a level: this crime alone never takes the heat past it).
- **`WantedResponses`** (`WANTR_*`): `level` (a `@Ref` to the level row), `what` (the game's word), `count`,
  `delay` seconds after the level is reached, `every` (again while it lasts; 0 once), `radius`, `param`,
  `sticky` (it goes on at the levels above its own), `searching` (also sent during the search).

Editor attributes: `@Ref(WantedLevels)` on a response's level, `@Range` and `@Unit` on the numbers,
`@AppendOnly @ByKey` on every registry.

## The phases: a `@Machine`

`WantedRow.phase` is an enum field moved only by the machine `WantedSteps`, whose rows live in
[`steps.lres`](steps.lres): `notice` (Clear to Wanted at level 1), `lose_them` (Wanted to Searching once the
subject has been out of sight longer than its level's `lose`), `spotted` (Searching to Wanted on a
sighting), `cooled` and `pardoned` (to Clear when the heat is gone). No row names an action: the tick asks
each guard, one transition a subject a tick. Heat does not fade while Wanted; it fades in Searching
and in Clear.

## Verbs

| | |
| --- | --- |
| `wanted_crime(subject, crime, x, z) -> float` | a crime: the heat added, 0 when it needed a witness and had none |
| `wanted_sighted(subject, x, z)` | the game's eyes have the subject now (the clock of "out of sight" starts over) |
| `wanted_add_heat`, `wanted_set_heat`, `wanted_set_level`, `wanted_pardon`, `wanted_forget` | story beats, a bribe, a leaver |
| `wanted_level / _heat / _phase / _unseen / _last_x / _last_z (subject)` | what the AI asks |
| `wanted_count()`, `wanted_subject_at(i)` | everyone with a row |
| `wanted_tick`, `wanted_reset`, `wanted_save`, `wanted_load`, `wanted_system()` | the system (`PH_SIMULATE`) |

The port `WantedWorld { witnessed(subject, x, z) -> bool, seed() -> int }` has defaults (every crime seen,
seed 1).

## Facts

`wanted_facts()` is a `Queue<WantedFact>` the game drains: `WANTED_CRIME` (crime, heat added, level, where),
`WANTED_LEVEL` (from, level), `WANTED_PHASE` (phase), `WANTED_CLEARED`, `WANTED_UNSEEN` (a crime nobody
saw), and `WANTED_RESPOND` (response row, count, level, and the subject's last known position) - the one
the AI turns into officers.

## Save

Section `wanted`, version 1: the clock, the dice, and a row a subject: its heat, when it was last sighted and
where. The phase is worked out again from them on the first ticks.

## Tests

`ludic test packages/ludic.wanted`: heat and level, repeats and caps, the unseen crime, the phases in and out
of sight, a sighting in the search, a pardon, responses once and repeating, and the save.
