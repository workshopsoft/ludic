bump: minor
type: change
**ludic.i18n draws plain text as it is: the English path is gone (phase 26.9).** `L` makes a key, a
key glued into text, or a line bracketed inside another; anything else - a player's name, a chat
line, a number - is drawn as it is, in every language, so a player named "Settings" stays
"Settings". Removed with it: the lookup of English words (exact lines, patterns with holes, a
paragraph a sentence at a time, padding), `Ln` (use `trn(kn"...")`), `i18n_pattern_count`, and an
English argument's own lookup inside a key's hole. A language `.po` is read for its keys and
plurals only. A game still on English msgids draws them untranslated until they are keys.
