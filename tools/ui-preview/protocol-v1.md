# ui-preview wire protocol, version 1 (frozen)

This is the whole contract between `ludic ui-preview` (the host) and a studio that spawns it. The
studio builds its process management and its canvas replay against this document and nothing else.
Version 1 is frozen: a change to any line format below is version 2, announced by `hello`. A later
v1 host may add a request or an event kind; a studio ignores reply lines it does not know.

## 1. Transport

- The studio starts `ludic ui-preview [--font DIR]` (or `bin/ludic-ui-preview` directly) and talks
  to it over stdin (requests) and stdout (replies). Nothing else is read or written except the files
  a request names. stderr carries only a start-up complaint about `--font`; ignore it.
- With no `--font`, the host loads the toolchain's default font (Noto Sans, baked, found under the
  install root as `fonts/noto-sans/baked`) and `hello` reports that directory as the font dir; a
  studio that wants to know whether it is the default compares it with its own copy of the path.
  `--no-default-font` starts with no font, as v1 hosts without a default did. Nothing in the
  line formats changes.
- Everything is UTF-8. A line ends with LF (`\n`); a CR before the LF of a request is dropped.
- One request is one line. The host answers every request, in order, with zero or more reply lines
  followed by exactly one **terminal line** (§3). It reads the next request only after writing and
  flushing that terminal line, so a studio may pipeline requests.
- End of stdin, or `quit`, ends the process with exit status 0.

## 2. Words

A line is a sequence of words separated by one or more spaces or tabs. A word is either:

- a **JSON value** - a string (`"..."`), an object (`{...}`) or a list (`[...]`) - read whole,
  whatever spaces, brackets or escaped quotes it holds; or
- a **bare word**: a run of characters other than space and tab.

In the request tables below, `<text>` is a JSON string or a bare word (a bare word is its own text);
`<num>` is a JSON number written bare (`12`, `-3.5`); `<json>` is a JSON value.
Template and stylesheet text contains line breaks, so it is always sent as a JSON string.

### 2.1 Quoting in replies

Every string the host writes - in a draw line, an event, an answer - is a JSON string quoted the same
way: `"` and `\` are escaped as `\"` and `\\`; LF, CR and TAB as `\n`, `\r`, `\t`; any other byte
below 0x20 as `\u00XX` (lower-case hex); every other byte, UTF-8 included, is written as it is. A
reply line never contains a raw LF.

### 2.2 Numbers in replies

- An integer (`<int>`) is written in decimal: `-12`, `0`, `640`.
- A real number (`<real>`) is rounded to the nearest thousandth, written with no exponent and with no
  trailing zeros or trailing point: `12`, `12.5`, `-0.125`, `0.333`. `-0` is written `0`. A value
  beyond 2,000,000 in magnitude is written as a whole number, truncated.
- A colour (`<rgb>`) is `#rrggbb`, six lower-case hex digits, 8 bits a channel, sRGB as the game
  draws it (no premultiplication). An alpha (`<a>`) is a `<real>` from 0 (clear) to 1 (opaque).
  Every primitive and style line that has a colour writes it as the pair `<rgb> <a>`.

## 3. Terminal lines

| Line | Meaning |
| --- | --- |
| `ok` | the request was done |
| `ok ui-preview 1 "<font dir>" "<locale>"` | the answer to `hello` only (§4) |
| `fail "<why>"` | the request was not understood or could not be done; nothing changed |

A template error is NOT a `fail`: the request succeeded and the error is reported as an `err` event
(§6) before the `ok`.

## 4. Requests

| Request | Reply before the terminal line |
| --- | --- |
| `hello` | none; the terminal line is `ok ui-preview <protocol> "<font dir>" "<locale>"`, protocol `1`, `""` for no font or English |
| `font <text dir>` | none. Reads `<dir>/font.json` (§5.3); `fail` if it has no `adv` list |
| `viewport <num w> <num h> [<num scale>]` | none. The frame's size in screen pixels, and screen pixels a design pixel; with no scale, `h / 1080` (the game's own rule). Default 1920 1080 |
| `locale <text po path>` | none. Every text a template shows is looked up in that gettext file as the game looks it up (ludic.i18n: exact, then patterns with holes, then sentence by sentence). `""` or `en` is English. The path is read through `file` overrides first |
| `load <text Name> <text xml> <text lss> [<text xml path> [<text lss path>]]` | events only (`err`). Registers component class `Name`, or replaces its template and styles in place if it exists. Paths default to `Name.xml` and `Name.lss`; they name the files in errors and rules, and an `@import` in the styles is resolved beside the lss path (§4.1). Every capitalised tag in the template naming a class not yet loaded gets an empty class (`<row/>`) of that name, filled in place when the studio loads it; the studio sends every class a story names before it `show`s the root |
| `model <text Name> <json object>` | none. The class's model: every key is a name its template reads. Props from the parent's tag and values the template `set`s are laid over it |
| `calls <text Name> <json object>` | none. How the class's functions answer (§7) |
| `show <text Name>` | none. The class a `frame` shows, as a whole screen; `fail` if it is not loaded |
| `native <text tag> [<num w> <num h>]` | none. `<tag>` becomes an element the game draws itself: laid out with that content size in design pixels (default 0 0), drawn as a `native` line. Declare natives before the templates that use them are loaded |
| `atlas <text prefix> <text name> <int cols> <int rows> [<json list of names>]` | none. `<img src="prefix:cell">` is a cell of atlas `name`: a `cols` x `rows` grid, cells numbered row by row from 0, named by the list (a cell is also reachable by its number) |
| `image <text path> <num w> <num h>` | none. A picture's natural size in pixels, for `object-fit`; an undeclared picture has none (it fills its box) |
| `hold <text id or key> <text pseudo>` | none, or `fail "no element …"`. Holds a pseudo-class on for that element from the next frame, on top of the real input: `hover`, `active`, `focus`, `focus-visible` (which is `focus` too), `checked`, `disabled`. `""` as the pseudo lets go of that element's holds; `hold "" ""` lets go of every hold. Holds are by the element's key, so they survive `model` and `load`; `reset` clears them. `tree`, `box` and `rules` answer as if the pseudo-class were real: `rules` lists the `:hover` / `:focus` rules it makes match. Added in v1 (a host without it answers `fail "unknown request hold"`) |
| `file <text path> <text contents>` | none. Reading `path` gives these contents (an imported stylesheet, a `.po`) instead of the disk's, until replaced; every class re-reads its styles at its next show |
| `input pointer <num x> <num y> <int buttons>` | none. Held until changed. Screen pixels; buttons is a mask: 1 left, 2 right, 4 middle |
| `input wheel <num d>` | none. Added to the next frame's wheel only |
| `input key <text name>` | none. Pressed in the next frame only. Names: `tab` `backtab` (shift-tab) `up` `down` `left` `right` `enter` `space` `escape` `backspace`, or a runtime key code as digits (a key-capture field) |
| `input text <text utf8>` | none. Typed in the next frame only (appended if sent twice) |
| `input shift <int 0/1>` | none. Held until changed |
| `input pad <text button> <int 0/1>` | none. Held until changed. Buttons: `a` (Enter), `b` (Escape), `up` `down` `left` `right` (a held direction repeats as the game's does), `enter` (Enter held down) |
| `frame [<num t>]` | the frame (§5), then events. `t` is the interface clock in seconds (animations, transitions, key repeat); it is the studio's to drive and may go backwards. Without `t` the clock stays where it was |
| `tree` | one `node` line an element of the last frame (§8) |
| `box <text id>` | a `box` line and its `style` lines (§8); `id` is an element's id or its key |
| `rules <text id>` | `rule` / `inline` lines, each followed by its `decl` lines (§8) |
| `reset` | none. The root's template state and component instances are forgotten, as a screen shown for the first time |
| `quit` | none; the process ends after `ok` |

Input takes effect in the next `frame`; a press's events are reported by that frame.

### 4.1 Paths

This is the rule v1 keeps. A later version will not change it silently.

- **The rule is for `@import` only.** A `locale` path and an `image` source are read exactly as written, relative to the host's working directory, and a `file` override for either uses that same text.
- **A leading `/` in an `@import`** means the game's root, which is the host's working directory. The slash is dropped: `@import "/src/ui/kit/theme.lss"` reads `src/ui/kit/theme.lss`. So an absolute filesystem path cannot be imported; start the host in the game's folder and write the path from there.
- **Any other `@import`** is joined to the directory of the sheet that imports it. For a class's own styles, that is its lss path as `load` gave it. For an imported sheet, it is that sheet's resolved path. So a sheet loaded as `src/ui/hud/Hud.lss` that imports `../kit/theme.lss` reads `src/ui/hud/../kit/theme.lss`, with no normalising of `..`. A class loaded under an absolute lss path imports under absolute paths.
- **A `file` override** applies to exactly the resolved path, byte for byte: `src/ui/kit/theme.lss` for the first example, and `src/ui/hud/../kit/theme.lss` for the second. Neither `/src/...` nor a normalised form matches.

## 5. The frame

```
frame <real t>
<draw line>
...
end
<event line>
...
ok
```

The draw lines are the UiBackend's calls, in the order ludic.ui made them, which is painting order:
draw each over the ones before. Coordinates are screen pixels from the viewport's top left, x right
and y down. Every draw line starts with its kind:

| Line | Draw |
| --- | --- |
| `rect <x> <y> <w> <h> <rgb> <a>` | a filled rectangle |
| `round <x> <y> <w> <h> <radius> <rgb> <a>` | a filled rectangle with every corner rounded by `radius` (the game clamps it to half the shorter side) |
| `ring <x> <y> <w> <h> <radius> <width> <rgb> <a>` | a rounded frame `width` thick, drawn inside that rectangle (a focus ring, an outline) |
| `text <x> <y> <size> <width> <rgb> <a> "<utf8>"` | one line of text; see §5.3 |
| `image path "<path>" <x> <y> <w> <h> <u0> <v0> <u1> <v1> <rgb> <a>` | a picture file stretched over the rectangle; the source rectangle is always `0 0 1 1` (the whole picture) in v1 |
| `image atlas "<atlas name>" <int cell> <x> <y> <w> <h> <u0> <v0> <u1> <v1> <rgb> <a>` | a cell of an atlas (`atlas` request); the rectangle is already the square the game draws it in (centred, the shorter side, whole pixels); the source rectangle is the cell's share of the sheet, in 0-1 of its width and height |
| `nine "<path>" <slice> <x> <y> <w> <h> <dst> <x0> <x1> <x2> <x3> <y0> <y1> <y2> <y3> <rgb> <a>` | `border-image`: the picture cut `slice` source pixels in from each of its four edges, into nine pieces; the corners are drawn `dst` wide into the columns `x0..x1`, `x1..x2`, `x2..x3` and rows `y0..y1`, `y1..y2`, `y2..y3` (already on whole pixels, and never more than half the box); the edges and the centre stretch |
| `clip <x> <y> <w> <h>` | from here on, draw only inside this rectangle |
| `unclip` | from here on, draw everywhere |
| `native "<tag>" <x> <y> <w> <h>` | a native element's box: the studio draws its placeholder (or a story's still) there |

**Colours.** `<rgb> <a>` is the colour to draw with and its opacity, every opacity around the element
already multiplied in. For `image` and `nine` it is a TINT multiplied into the picture's own colours
(`#ffffff 1` draws the picture as it is).

**Clips do not nest in the list.** ludic.ui intersects nested clips itself: every `clip` line is the
whole clip from then on, replacing the one before, and `unclip` removes it. A frame starts
unclipped, and the next frame starts unclipped again.

### 5.3 Text

- `x`, `y` is the TOP LEFT of the line box, not the baseline. The game's overlay puts the baseline at
  `y + 0.8 * floor(size)`, and draws each glyph from font.json's cell with `pad_x` / `base_y`.
- `size` is the font size in screen pixels as ludic.ui asked for it; the game draws and measures at
  `floor(size)` pixels an em.
- `width` is the run's MEASURED width in screen pixels, from the host's own copy of the game's
  metrics: for each code point, its glyph's `adv` (from font.json; a control character is the space,
  a code point the atlas lacks is `?`) times `floor(size)`, summed, the sum truncated to a whole
  pixel. Line breaking, `text-fit: shrink` and ellipses were decided with the same numbers, so the
  studio's own rendering of the run should be fitted to `width`.
- With no font loaded (`hello` says `""`: only with `--no-default-font`, or an install without
  `fonts/`), every code point measures half of `floor(size)`.
- The string is the text as drawn: already translated (`locale`), already wrapped (one line a `text`
  line) and already cut with its ellipsis. A text-shadow is its own `text` line, drawn before.

## 6. Events

Events are what happened while a request ran. They are written after the request's own reply lines
(after `end` for a frame) and before the terminal line, in the order they happened. Each is one line:

| Line | Meaning |
| --- | --- |
| `err "<file>" <int line> <int col> "<message>"` | a template or stylesheet error. `file` and `line` are where the element or stylesheet was written when ludic.ui knows it (`""` and `0` when not); `col` is always `0` in v1. The message is ludic.ui's, with the `file:line: ` it began with taken off. Each distinct error is said once; a `load` forgets them, so the next frame says again whatever is still wrong |
| `call "<Class>" "<name>" <json list of arguments>` | an action (a press, a key, a fired event) called a function of that class. Calls made while a frame's tree is built are not events: they are the story answering |
| `set "<Class>" "<name>" <json value>` | an action set the class's state `name` (`set name = value`); the value is kept and laid over the model from then on |
| `emit "<name>"` | an action ran `emit name` (a click is `press`), whether or not a parent handled it |
| `sound "<name>"` | a control asked for a sound (`click`, or its `sound="..."`) |
| `miss "<Class>" "<name>"` | a frame's build called a function `calls` does not answer; it answered `null`. Said once a class and name |

JSON values in events are written on one line with the quoting of §2.1 and the numbers of §2.2.

## 7. Function answers (`calls`)

`calls <Name> {"<function>": <answer>, ...}`. A template's call `f(args...)` on an instance of the
class is answered from `<answer>`:

- a JSON list: its item at the first argument (as an int); `null` past its end;
- a JSON object: its value under the arguments' texts joined by `,` (`"0"`, `"food"`, `"2,3"`), else
  under `"*"`, else `null`;
- anything else: that value, whatever the arguments.

A constant object is written as `{"*": {...}}`. A name the table does not have answers `null` (and a
`miss` event during a build). `set name = value` never reaches the table.

## 8. Inspection replies

`tree` - one line an element of the last frame shown, depth first:

```
node <int depth> <int kind> "<key>" "<tag>" "<id>" "<classes>" <x> <y> <w> <h> "<text>"
```

`kind` is ludic.ui's: 0 box, 1 text, 2 spacer, 3 button, 4 scroll, 5 image, 6 rule, 7 native.
`key` is the element's key (unique in the frame, usable in `box` / `rules`); `tag` is `""` for a
node the template did not name (a text run); `classes` is space-separated.

`box <id>`:

```
box "<key>" <x> <y> <w> <h>
style font-size <real>
style color <rgb> <a>
style background <rgb> <a>          (or: style background none)
style opacity <real>
style padding <top> <right> <bottom> <left>
style margin <top> <right> <bottom> <left>
style border-width <top> <right> <bottom> <left>
style border-color <rgb> <a>        (or: style border-color none)
style border-radius <real>
style gap <real>
style flex-grow <real>
style flex-direction row|column
style align-items start|center|end|stretch
style justify-content start|center|end|space-between|space-around|space-evenly
style position static|relative|absolute|fixed <int z-index>
style content <w> <h>
style enabled true|false
```

Lengths are screen pixels, after the cascade and layout; `content` is the measured content size.
A later v1 host may add `style` lines; a studio ignores names it does not know.

`rules <id>` - the stylesheet rules that match the element now (its `:hover` and the viewport's
`@media` included), in the order the cascade applies them (the later wins), then its `style="..."`:

```
rule "<file>" <int line> <int specificity> "<selector>"
decl "<property>" "<value>"
...
inline "" 0 0 ""
decl "<property>" "<value>"
```

`file` and `line` are where the selector was written (the default sheet is `"the default sheet"`);
`value` is the declaration as written when it is plain text, and `""` when it is an expression
(`{...}`), which is evaluated per element.

## 9. Example

```
> hello
< ok ui-preview 1 "" ""
> load "Pill" "<row class=\"pill\"><p>{label}</p></row>" ".pill { background: #203040; }"
< ok
> model "Pill" {"label": "Food"}
< ok
> show Pill
< ok
> frame 0
< frame 0
< rect 0 0 1920 1080 ...
< text 0 0 16 32 #eeeeee 1 "Food"
< end
< ok
```

(The draw lines of a real frame depend on the templates and the default sheet; `smoke.txt` has a
transcript with what each line must contain.)
