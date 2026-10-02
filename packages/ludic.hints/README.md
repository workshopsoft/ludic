# ludic.hints

A rail of things that are true now and can be acted on now - thirsty, the fire burning low, a
bear near, a job ready to hand in - sorted by how much they matter, each one a card that teaches
it in three steps and can be muted for good. Uses [`ludic.base`](../ludic.base/README.md) and
nothing else.

```ludic
import "ludic.hints"
```

The package never reads a key and never draws: the game's input calls the verbs (the key opens
and puts down, the arrows walk, a third key mutes), its interface reads the rail and the card,
and its words are the cards' own text keys, translated where they are drawn.

## Cards are data

```ludic
def Hints from "assets/data/hints.lres"        # the game's cards, in an open registry
```

```
thirsty {
  urgency: HINTS_NOTE, icon: "bottle", item: IT_BOTTLE
  line: "Thirsty - drink", title: "Water"
  s1: "Drink at any shore, for nothing", pic1: "waterfull"
  s2: "Fill a bottle there as well", item2: IT_BOTTLE
  s3: "Boil it in the pot to be safe", item3: IT_BOILED
  later: "Buy or make a bottle, fill it at the shore and boil it."
}
```

`urgency` is `HINTS_TIP`, `HINTS_NOTE`, `HINTS_WARN` or `HINTS_URGENT`; `priority` (0..9, default 0) orders
cards of one urgency, so a card true only for a while can outrank a standing tip. A picture is a glyph by
name (`icon`, `picN`) or a thing's picture by number (`item`, `itemN`, -1 for none) - both the
game's to interpret.

## The rules it keeps

1. **The most urgent few.** Once a pass (a second by default) the rail is the true, unmuted cards,
   most urgent first, then by `priority` (0..9, higher first) within an urgency, then in registry order, up to `hints_config`'s count.
2. **A card follows its subject.** As the rail re-sorts under an open card, the pick follows it;
   when what it was about stops being true (or the rail stops showing) it is put down, with no fact.
3. **A lesson lands once.** `hints_mute_card()` takes the open card off the rail until
   `hints_unmute_all()`. Mutes are kept **by key**, so a card added or removed moves nobody else's,
   and a key this build does not know is carried through a load and a save.

## The port

```ludic
export port HintsWorld {
  true_now: fn(int) -> bool   # is card i true now? pure and cheap (unbound: never)
  showing: fn() -> bool       # the rail is wanted: in play, the player's switch on (unbound: yes)
}
```

## API

| | |
| --- | --- |
| `HintCard { key, urgency, priority, icon, item, line, title, s1..s3, pic1..pic3, item1..item3, later }`, `open registry Hints ... as HINT` | a card |
| `hints_config(shown, every)` | how many the rail holds (3) and seconds between passes (1) |
| `hints_tick(dt)`, `hints_sort()`, `hints_refresh()` | a pass when due, a pass now, the next tick's pass now |
| `hints_rail() -> []int`, `hints_count()`, `hints_at(k)`, `hints_pick()`, `hints_hot(k)` | the rail |
| `hints_card()`, `hints_key()`, `hints_open(k)`, `hints_close()`, `hints_move(d)` | the card being read (-1) and its verbs |
| `hints_step_text(id, n)`, `hints_step_icon(id, n)`, `hints_step_item(id, n)` | a step, n 1..3 |
| `hints_mute_card()`, `hints_mute(id, on)`, `hints_muted(id)`, `hints_mute_count()`, `hints_unmute_all()` | "I know this" |
| `hints_mutes_save() -> Val`, `hints_mutes_load(v)` | the mutes as a list of keys, for the game's settings file |
| `hints_facts() -> Queue<HintsFact>` | `{ what, card }`: `HINTS_F_OPENED`, `_CLOSED`, `_MUTED`, `_UNMUTED` |
| `hints_system() -> System` | `"hints"`, `PH_PRESENT`: reset and the tick; nothing in a trip's save |

## Tests

```bash
ludic test packages/ludic.hints
```
