# ludic.i18n

A game in any language, from gettext files anyone can add. The code names text by KEYS, never by its
English: a key says what a text is FOR (`pause.resume`), `en.po` says what it says in English, and
every other language is a `.po` keyed the same way. Text is made at the moment it is drawn, so a
line that reaches the screen is covered wherever it was built. Uses nothing - not even
`ludic.base`; the font atlas and the mod folder are the game's, through a port.

```ludic
import "ludic.i18n"
i18n_use("tr")                                     # from settings; the atlas follows
ov_text(x, y, 16, L(tr(k"pause.resume")), ...)     # "Resume"; "Devam" in Turkish
ov_text(x, y, 16, L(trf(k"hud.day", `{day}`, "", "", "")), ...)
ov_text(x, y, 16, L(trn(kn"pack.items", n, "", "", "")), ...)
```

## Keys

A key travels as a string with a marker byte in front (the compiler's `k"pause.resume"` is exactly
that; `kn"..."` a plural key), so code that makes text never takes the language's state: the text is
made where it is drawn, by `L`.

- A key's text is the language in use's, else en.po's (read from the languages' directory the first
  time a key is asked for), else the key itself - `[[key]]` in a developer's build (`i18n_loud`),
  said once.
- Holes `{1}` .. `{4}` take `trf`'s arguments in the language's own order, and a translation may
  reorder or drop them; an argument that is a key is made into its text first. A plural's count is
  `{1}`, and its form is the language's `Plural-Forms` rule's.
- A key's line inside another's hole survives: an argument's own separators are escaped outside
  brackets, and a line bracketed with bytes 29 .. 30 (a game's nested line) rides raw and is made
  first, outermost in.
- **Anything without a marker is drawn as it is**, in every language: a player's name, a chat line,
  a number, a path. There is no lookup by English words, so a player named "Settings" stays
  "Settings". A key glued into such text (`"Photo: " + tr(k"...")`) is still made where it sits,
  an interim help for code on its way to a key of its own.

## Where languages come from

Later ones replace earlier ones with the same code:

- `<dir>/languages.txt` - the ones that ship, one code per line (`#` a comment), each `<dir>/<code>.po`.
- every `*.po` in the mod folder the port names - a player drops a file in and picks it. No build.

`X-Language-Name` in the header is what a menu shows; `X-Font` names a font atlas directory beside
the `.po`, for a script the default atlas does not carry; `Plural-Forms` picks the plural rule. A
language that lacks a key draws its English, so a partial file is always playable.

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
| `L(s) -> string` | what the game draws, in the language in use (made once per distinct line, kept) |
| `tr(k: Key)`, `trf(k: Key, a, b, c, d)`, `trn(k: Key, n, a, b, c) -> string` | a key (`k"..."`), a key with its holes' arguments, a plural key (`kn"..."`) by `n`: made into text by `L` |
| `i18n_key(name)`, `i18n_key_plural(name)`, `key_text(k)`, `i18n_is_key(s)` | a key named at run time, its name without the marker, whether a string is one |
| `i18n_base_text(text)`, `i18n_loud(on)` | the base (en.po) from text, for a test; a developer's build's loud missing key |
| `i18n_init()`, `i18n_count()`, `i18n_index(code)`, `i18n_code_at(i)`, `i18n_name_at(i)`, `i18n_font_at(i)`, `i18n_mod_dir()` | the languages found, "en" first |
| `i18n_use(code)`, `i18n_off()`, `i18n_on()`, `i18n_current()` | choosing one; whether anything is translating |
| `i18n_font_base(dir)`, `i18n_font_now()` | the atlas the overlay was opened with, and the one it has now |
| `i18n_load_text(text)`, `i18n_parse(text) -> []PoEntry`, `i18n_header(text, field)` | a `.po` from text, outright |
| `i18n_exact_count()`, `i18n_plural_rule()`, `i18n_plural_form(rule, n)`, `PL_*` | what the file gave |
| `i18n_find`, `i18n_starts`, `i18n_ends` | the byte helpers, for a game that wants them |

## Tests

```bash
ludic test packages/ludic.i18n
```

`keys_test`: keys, holes, plurals, a key glued into text, plain text as it is. `nest_test`: lines
inside lines, bare, bracketed and escaped. `i18n_test`: a shipped list and a mod folder in the temp
directory, a language's keys, plurals (a Russian-shaped rule), the font and its fallback, a mod
replacing a shipped code, a forced code.
