# ludic.save

A save file's contract across releases, generic over what the file holds. Every shipped game meets
it on its second release: the tables a save is indexed by grow, keys are added, meanings shift, and
a file written by 0.1 has to open in 0.2 - or be refused with a sentence the player can act on,
never silently read as rubbish. Uses nothing.

(`ludic.base`'s save tree is the other half: a mechanic's own section inside a file, by key. This
package is the file.)

```ludic
import "ludic.save"
def SaveMigrations trip_3_4 { format: "trip", from: 3, run: fn trip_mig_3_4 }

let f = save_format("trip", 6)                     # this build writes 6
f.is_one = fn looks_like_a_trip                    # an object with a day in it
let r = save_open(path, backup, f)                 # read, check, carry forward, or the backup
if r.status == SAVE_OK { apply(r.value) }
...
save_write(path, backup, Json.encode(v))           # false unless it is on disk
```

## The contract

- **A version in the file**, under `version_key` (`"version"`); a file without one is 1.
- **A chain of migrations**, one step per version, each rewriting the parsed object in place, so an
  old file is brought to today's shape once and every reader after it sees only that shape - no
  reader grows an `if version < n`. The game declares its steps into the open registry
  `SaveMigrations` (`{ format, from, run }`); a version with no step changed nothing.
- **A torn write is told from a whole one** by the text (`save_text_intact`: every brace, bracket and
  string closed). A best-effort JSON parser hands back half a file as a shorter, plausible one.
- **A backup, and only of a whole file**: `save_write` copies the old file aside when it is intact,
  writes, and reads the text straight back. A caller about to delete something on the strength of
  the answer needs to know it is on disk.
- **A newer build's file is refused and read-only.** It is never replaced by its backup (that is from
  the newer build too), and `save_write_to` refuses a read that says `readonly`. Both copies damaged
  is read-only as well. Never write over a file you could not read.

The package never words anything: a status is a number, and the game says it.

## API

| | |
| --- | --- |
| `SaveFormat { name, version, oldest, version_key, is_one }`, `save_format(name, version)` | a kind of file |
| `SaveMigration { key, format, from, run }`, `open registry SaveMigrations as SMIG` | one step, declared by the game |
| `SaveRead { status, from, migrated, readonly, from_backup, value }` | how one read went |
| `SAVE_OK`, `SAVE_NONE`, `SAVE_CORRUPT`, `SAVE_FUTURE`, `SAVE_STATUS_COUNT` | the statuses; a game's own refusals (another map) start at the count |
| `save_parse(text, f)`, `save_read(path, f)` | whole, parsed, an object, one of these |
| `save_upgrade(r, f) -> bool` | the version checks and the chain |
| `save_open(path, backup, f) -> SaveRead` | both, with the backup standing in for a damaged file |
| `save_migrate(v, f, from)`, `save_step(format, n)`, `save_steps_doubled(f)` | the chain outright; a step declared twice |
| `save_write(path, backup, text) -> bool`, `save_write_to(r, path, backup, text)` | the write, backed up and read back |
| `save_text_intact(s)` | the torn-write test |
| `save_strip(v, key)`, `save_list_with(l, slot, n)`, `save_list_without(l, slot)`, `save_int(v, key, fallback)` | what migrations keep doing |
| `save_fold(h, s)`, `save_fold_int(h, n)` | a fingerprint of the tables a file stores by position: an append refreshes it, an insert needs a step |

## Tests

```bash
ludic test packages/ludic.save
```

A toy format at version 3 with two steps and another format's step beside them: torn files, rubbish
and the wrong kind of file, the chain from 1, a newer file refused and read-only, the backup standing
in and never over a newer file, a write that backs up only a whole file.
