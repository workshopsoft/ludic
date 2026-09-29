bump: minor
type: feature
**Text keys: `k"pause.resume"`, a `Key`, checked against `en.po`.** A text the player reads is named by
a key of the new builtin type `Key` (`kn"..."` for a plural) - not a string, and no string one; at run
time its text after a marker byte, so a runtime's `tr` is a cast. `lang "assets/lang" en` in
`package.ludic` names the source language's `.po`, and the compiler holds every key to it: a key
literal, a template's `t('key', ...)` and a registry's derived `@Text` key (`<registry>.<row>.<field>`,
or `@TextKey("steps")`'s prefix; filled into a `Key` field a row leaves out) must be there, a plural
one with a `msgid_plural`; `trf` / `trn` / `t()` given another number of values than the English has
holes, text still written in English (a template's words, a `@Text` row's value - counted as
`english_left` by `ludic deps`) and one English split into keys without `#.` descriptions are
warnings. `ludic schema` gains `"lang"`: every key with its sites, unused and undescribed keys, splits,
and each other language's missing, fuzzy and extra keys.
