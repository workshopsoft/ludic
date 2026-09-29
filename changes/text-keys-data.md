bump: minor
type: change
**The packages' registry text is keys (phase 26.4).** The fields a player reads in the open registries
a game fills are `@Text ... : Key` now, so a compiled row that leaves one out takes its derived key
(`<registry>.<row>.<field>`) and the English lives in the game's `en.po`: ludic.things' `ThingKind.name`,
ludic.gear's `GearKind.blurb` / `howto` / `names` (`[]Key`), ludic.hints' `HintCard` line, title, steps
and `later`, ludic.jobs' `JobDef.title` / `text` / `how`, ludic.npc's `NpcLine.text` and
`NpcChoice.text`, and ludic.weather's `WeatherKind.name`. What a package hands back as text
(`thing_name`, `gear_level_name`, `hints_step_text`, `npc_words`, `weather_name`) is the key's marked
text, "" for none, made into words where it is drawn. Not text, so no longer `@Text`: ludic.npc's
`NpcName.name` (a person's name, the same in every language), `NpcChoice.line` (a line's key) and
ludic.settings' `SettingDef.text` (a text setting's default value). ludic.i18n's `tr`, `trf`, `trn`
and `key_text` say `@alloc_ok`: `tr` is a cast, and what `trf` / `trn` make is kept by what shows it.
