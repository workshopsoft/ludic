# ludic.i18n

A game in any language, from gettext files anyone can add. English is the source and stays in the
code: nothing here, and nothing a translator does, rewrites a string in the game. A language is a
`.po` keyed by the English exactly as the game draws it, and text is translated at the moment it is
drawn, so a string that reaches the screen is covered wherever it was built. Uses nothing - not
even `ludic.base`; the font atlas and the mod folder are the game's, through a port.

```ludic
import "ludic.i18n"
i18n_use("tr")                      # from settings; the atlas follows
ov_text(x, y, 16, L("Settings"), ...)
ov_text(x, y, 16, L(`Day {day}`), ...)            # "Day {1}" in the file matches "Day 12"
ov_text(x, y, 16, Ln("{1} trout", "{1} trout", n), ...)
```

## Where languages come from

Later ones replace earlier ones with the same code:

- `<dir>/languages.txt` - the ones that ship, one code per line (`#` a comment), each `<dir>/<code>.po`.
- every `*.po` in the mod folder the port names - a player drops a file in and picks it. No build.

`X-Language-Name` in the header is what a menu shows; `X-Font` names a font atlas directory beside
the `.po`, for a script the default atlas does not carry; `Plural-Forms` picks the plural rule.

## What a msgid can be

- `"Hold to break off deadwood"` - an exact string.
- `"Day {1}"` -> `"{1}. Gün"` - a pattern: the English around the holes must match, the holes are
  whatever the game put there, and a translation may reorder or drop them. A hole's own text is
  translated too when the file knows it - an item name, or "a deer" with its English article taken
  off. Of several patterns that match, the one pinning down the most English wins.
- A paragraph the game assembled from sentences is tried whole, then a sentence at a time; the
  padding a layout put round a word ("   owned") is taken off and put back.
- `msgid_plural` / `msgstr[k]` - `Ln(one, many, n)`, by the file's `Plural-Forms`.

Whatever has no translation draws in English, so a partial file is always playable.

## Keys (phase 26: the form that replaces English in the code)

A key names what a text is FOR (`pause.resume`), and `assets/lang/en.po` says what it says in English,
like any other language. A key travels as a string with a marker byte in front (the compiler's
`k"pause.resume"` is exactly that; `kn"..."` a plural key), so code that makes text never takes the
language's state: the text is made where it is drawn, by `L`.

```ludic
L(tr(k"pause.resume"))                             # "Resume"; "Devam" in Turkish
L(trf(k"catch.saw", tr(k"species.elk.a_name"), "5:30", "", ""))   # "You saw an elk at 5:30."
L(trn(kn"pack.items", n, "", "", ""))              # "{1} items" by the language's plural rule
```

- A key's text is the language in use's, else en.po's (read from the languages' directory the first
  time a key is asked for), else the key itself - `[[key]]` in a developer's build (`i18n_loud`),
  said once.
- Holes `{1}` .. `{4}` take `trf`'s arguments in the language's own order; an argument that is a key
  is made into its text first. A plural's count is `{1}`.
- A string with no marker takes the English path below, so a game moves over a file at a time.

## Config and port

```ludic
i18n_config(dir, default_font)                      # "assets/lang", "assets/kit/font" unless said
port I18nWorld {
  mod_dir: fn() -> string          # a player's own .po files; "" none (the default)
  forced: fn() -> string           # a code that wins over the one asked for (a test); "" none
  font_ready: fn() -> bool         # is there an overlay to load an atlas into (default no)
  set_font: fn(string) -> bool     # load that atlas directory
}
```

## API

| | |
| --- | --- |
| `L(s) -> string` | what the game draws, in the language in use (cached) |
| `Ln(one, many, n) -> string` | a count's form, with `{1}` the count; English is one for 1, many otherwise (the old form) |
| `tr(k: Key)`, `trf(k: Key, a, b, c, d)`, `trn(k: Key, n, a, b, c) -> string` | a key (`k"..."`), a key with its holes' arguments, a plural key (`kn"..."`) by `n`: made into text by `L` |
| `i18n_key(name)`, `i18n_key_plural(name)`, `key_text(k)`, `i18n_is_key(s)` | a key named at run time, its name without the marker, whether a string is one |
| `i18n_base_text(text)`, `i18n_loud(on)` | the base (en.po) from text, for a test; a developer's build's loud missing key |
| `i18n_init()`, `i18n_count()`, `i18n_index(code)`, `i18n_code_at(i)`, `i18n_name_at(i)`, `i18n_font_at(i)`, `i18n_mod_dir()` | the languages found, "en" first |
| `i18n_use(code)`, `i18n_off()`, `i18n_on()`, `i18n_current()` | choosing one; whether anything is translating |
| `i18n_font_base(dir)`, `i18n_font_now()` | the atlas the overlay was opened with, and the one it has now |
| `i18n_load_text(text)`, `i18n_parse(text) -> []PoEntry`, `i18n_header(text, field)` | a `.po` from text, outright |
| `i18n_exact_count()`, `i18n_pattern_count()`, `i18n_plural_rule()`, `i18n_plural_form(rule, n)`, `PL_*` | what the file gave |
| `i18n_find`, `i18n_starts`, `i18n_ends` | the byte helpers, for a game that wants them |

## Keeping an extractor working

A game's extractor finds the English by reading its own source for literals (Maroon Lake's
`tools/i18n/extract.py`); nothing here changes what it reads. Build sentences a translator can
find: one template literal with holes, not fragments glued with `+`.

## Tests

```bash
ludic test packages/ludic.i18n
```

A shipped list and a mod folder in the temp directory: exact lines, patterns with translated holes
and articles, paragraphs, padding, plurals (a Russian-shaped rule), the font and its fallback, a mod
replacing a shipped code, a forced code, and English untouched.
