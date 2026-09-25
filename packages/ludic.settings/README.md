# ludic.settings

A game's settings as data, in one store with one owner. The game declares them - usually as a
registry of `SettingDef` read from a `.lres` - and everything else reads and writes them through
the store's verbs. A change is a `SettingChanged` fact the game drains to apply it. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.settings"
export registry Settings of SettingDef as SET from "assets/data/settings.lres"
for i in 0 .. SET_COUNT { settings_add(Settings[i]) }       # SET_* is each setting's id
```

```
# settings.lres - the entry's name is the key in the file
bloom { kind: SETTING_BOOL, num: 1.0 }
shadow_q { kind: SETTING_INT, num: 2.0, lo: 0.0, hi: 3.0, rescue: true }
rscale { kind: SETTING_FLOAT, num: 0.78, lo: 0.5, hi: 1.0, rescue: true }
lang { kind: SETTING_TEXT, text: "en" }
```

## API

| | |
| --- | --- |
| `SettingDef { key, kind, num, text, lo, hi, rescue, saved }` | a setting: `SETTING_BOOL` / `_INT` / `_FLOAT` / `_TEXT`, its default (`num` or `text`), its range (`hi < lo` is none), whether a rescue start puts it back, whether it is written |
| `settings_add(d) -> int`, `settings_clear()`, `settings_count()`, `settings_def(id)`, `settings_id_of(key) -> int` | the table; an id is the place a setting was added |
| `settings_get_bool / _int / _float / _text(id)` | the value |
| `settings_set_bool / _int / _float / _text(id, v)`, `settings_set_value(id, Val)` | a change, held to the range (outside it is the default) and reported |
| `settings_changes() -> Queue<SettingChanged>` | the facts: `{ id, key }`, one per change |
| `settings_reset_all()`, `settings_clamp_all()`, `settings_rescue()`, `settings_is_safe(id)` | the whole store at once, quietly: defaults, ranges, the rescue set |
| `settings_to_json() -> Val`, `settings_put(v, id)`, `settings_from_json(v)` | the file, by key: a switch is 0/1, a float thousandths; a key the file lacks keeps the store's value |

## Tests

```bash
ludic build packages/ludic.settings/tests/settings_test.ludic --headless -o /tmp/settings_test && /tmp/settings_test
```
