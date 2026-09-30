bump: minor
type: feat
**The RTS mechanics: `ludic.rts`, `ludic.build`, `ludic.produce`, `ludic.harvest`** - what an Age-of-Empires-like game is built
from, each a mechanic of `ludic.base` alone (ports for the world, queues of facts, verbs, its own save section), none
depending on another, and every kind of content a row of data a studio can edit.

- **`ludic.rts`** - a selection per player (click, box, shift), ten control groups, an order queue per unit with shift-queue, and
  formations and stances. Orders are rows of `RtsOrders` with a mode the logic knows (`RTS_M_POINT`, `CHASE`, `WORK`, `PATROL`,
  `STOP`, `HOLD`); move, attack-move, attack, gather, build, patrol, stop and hold ship as data. Execution asks the world through
  `RtsWorld` (positions, a path, reach, an enemy to pick) and says `RTS_F_ENGAGED`, `ARRIVED`, `LOST_TARGET` and the rest as facts.
- **`ludic.build`** - footprints of w x h cells turned a quarter at a time, placement rules per kind (tags every cell needs or must
  lack, next to a finished structure, apart from another, what the owner must have, a limit), a cost taken through `BuildBank`, and
  construction as a `@Machine` (Placed, Building, Done, Destroyed) that workers progress, with a pace curve per kind.
- **`ludic.produce`** - a queue per building of items from data (time, cost, supply, tech, once-only upgrades), queue limits, cost
  at the queue or at the start, refund percentages for cancelling, a rally point or entity, held until supply and room allow.
- **`ludic.harvest`** - resource nodes (amount, slots, regrowth, vanishing), gatherer classes (capacity, pace per resource),
  drop-offs, and the gather-carry-drop loop as a `@Machine` whose rows live in `steps.lres`; a spent node is left for the next one
  near it. The stockpile is the `HarvestBank` port.
