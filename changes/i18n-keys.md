bump: minor
type: feature
**`ludic.i18n`: keys (phase 26).** A key names what a text is for, and `en.po` says it in English like any
other language. A key is a string with a marker byte (`I18N_KEY`, `I18N_PLURAL`), its arguments after
byte 31, so the code that makes text never takes `I18nState`: `tr(k)`, `trf(k, a, b, c, d)` and
`trn(k, n, a, b, c)` build it, and `L` makes it into text where it is drawn - the language in use, else
en.po (read the first time a key is asked for), else the key itself, `[[key]]` in a developer's build
(`i18n_loud`). Holes take their arguments in the language's order, a key argument made first; plural
keys go by each language's rule. A string with no marker takes the old English path, so a game can
move over a file at a time.
