# ludic.launcher

A game's first screen, generic: Play or Continue, the news, a way into settings, the update's
progress, a note that the game crashed last time, the language, quit. The screen is
[`ludic.ui`](../ludic.ui/) components; what it says and offers is **rows the game fills in a
`.lres`** (so Ludic Studio edits them with its attribute editors); what it asks of the game is two
ports; what the player did comes out as facts. Nothing in it names a game, and it never starts,
builds or quits anything - the game drains the facts and does that.

```ludic
import "ludic.launcher"
```

Its module line is `module ludic_launcher uses ludic_base, ludic_ui`: the mechanic contract of
[`ludic.base`](../ludic.base/README.md) (ports for questions, a queue for facts, verbs for changes)
plus the UI it draws with. It reaches neither `ludic.update` nor `ludic.i18n`; the game binds their
answers to its ports (`tests/wiring_test.ludic` is that glue, compiled and run).

## The data

Four open registries, filled with `def Launchers from "data/launcher.lres"` and the like:

| Registry (prefix) | Record | What a row is |
| --- | --- | --- |
| `Launchers` (`LC`) | `LauncherDef` | the launcher's look: `title`, `tagline` (`@Text`), `logo`, `art`, `background` (`@Asset("png")`), `accent`, `shade` (`@Color`), `news_url`, `news_max`, `news_refresh`, `show_version`, `show_language` |
| `LauncherButtons` (`LB`) | `LauncherButton` | a menu button: `order`, `label` (`@Text`), `verb`, `arg`, `icon`, `primary`, `when`, and `launcher` (which row it is for; empty: every launcher) |
| `LauncherLinks` (`LL`) | `LauncherLink` | a small link along the bottom: `order`, `label`, `url`, `icon` |
| `LauncherNews` (`LN`) | `LauncherNewsRow` | news that ships with the game: `order`, `title`, `body`, `date`, `tag`, `url`, `image` |

```
main {
  title: k"launchers.main.title"      # or leave it out: the compiler derives that key
  tagline: k"launchers.main.tagline"
  logo: "assets/launcher/logo.png"
  art: "assets/launcher/art.png"
  background: "assets/launcher/bg.png"
  accent: 0xE8B04A
  news_url: "https://example.test/news.json"
  news_max: 4
}
```

```
continue { order: 10, label: k"launcher_buttons.continue.label", verb: "continue", when: "save", primary: true }
play     { order: 20, label: k"launcher_buttons.play.label", verb: "play", when: "no_save", primary: true }
update   { order: 25, label: k"launcher_buttons.update.label", verb: "update", when: "update" }
settings { order: 40, verb: "settings" }
news     { order: 50, verb: "news" }
language { order: 60, verb: "language" }
site     { order: 70, verb: "link", arg: "https://example.test/" }
quit     { order: 90, verb: "quit" }
```

- **Verbs** (`LauncherButton.verb`): `play`, `continue`, `new_game`, `settings`, `update`,
  `crash_report`, `crash_dismiss`, `link` (`arg` is the address), `quit` and `custom` (`arg` is the
  game's own word) leave a fact; `news` and `language` open the launcher's own panel.
- **`when`**: `always` (the default), `save` (the game has one), `no_save`, `update` (a newer version
  is available), `crash` (the last run crashed and the note is not put away). Buttons are kept in
  `order`; the first shown `primary` is the big one and takes the focus (else the first).
- A `language` button shows only when the row's `show_language` is on and the game offers two or more;
  `quit` only when the game's `can_quit` says yes.
- Everything is per launcher row: `launcher_use(st, "main")` picks one (the first row is used until
  then), and a button, link or news row with `launcher: "main"` belongs to that row alone.
- **News** starts as the rows (in `order`), then the feed's items follow, read in the language in
  use. A feed is `[...]` or `{"items": [...]}` of `{"title", "body", "date", "tag", "url", "image"}`;
  a `title` or `body` may be `{"en": "...", "tr": "..."}`. An item with no title is skipped. The feed is
  asked once, and again every `news_refresh` seconds when that is above 0; a feed that fails, or is
  not one, leaves the rows.

## The ports

Every member has an answer for a game that binds nothing (no save, no update, one language, no crash), so
the launcher always shows. The launcher asks them **once a frame, in `launcher_tick`**, and keeps the
answers: the components and their events read only what it kept.

```ludic
export port LauncherWorld {
  has_save: fn() -> bool             # Continue is offered while there is one
  version: fn() -> string            # this build's version, for the footer
  update_state: fn() -> int          # LU_NONE, LU_CHECKING, LU_AVAILABLE, LU_DOWNLOADING, LU_WORKING, LU_APPLYING, LU_FAILED, LU_CURRENT
  update_version: fn() -> string     # the newer version's name
  update_progress: fn() -> int       # 0..1000 over every byte
  update_eta: fn() -> int            # seconds left, -1 until known
  update_error: fn() -> int          # LE_NONE, LE_OFFLINE, LE_CORRUPT, LE_NOT_INSTALLED, LE_OTHER
  language: fn() -> string           # the code in use
  language_count: fn() -> int
  language_code: fn(int) -> string
  language_name: fn(int) -> string   # each in its own words
  crashed: fn() -> bool              # THE CRASH SLOT: the last run ended in a crash (ludic.crash, or the game)
  crash_summary: fn() -> string      # one line for the slot
  crash_can_report: fn() -> bool     # a report can be sent
  can_quit: fn() -> bool             # a build that cannot close itself says no
}
export port LauncherNet { get, poll, text, free, now_s }   # the feed; Http by default
```

`LU_*` and `LE_*` are the launcher's own codes; `tests/wiring_test.ludic` maps `ludic.update`'s
states onto them (`UPDATE_NEWER` to `LU_AVAILABLE`, `UPDATE_FETCH` to `LU_DOWNLOADING`,
`UPDATE_ERR_CORRUPT` to `LE_CORRUPT`, and so on) and `ludic.i18n`'s languages onto the language
members. The crash slot is a port on purpose: `ludic.crash` (or the game) binds `crashed`,
`crash_summary` and `crash_can_report`; until something does, the slot is empty and draws nothing.

## Facts

What only the game can do is pushed on `launcher_facts(st)`, a `Queue<LauncherFact>` the game drains
in a later phase:

| `what` | when | `arg` |
| --- | --- | --- |
| `LF_PLAY`, `LF_CONTINUE`, `LF_NEW_GAME` | the button with that verb | |
| `LF_SETTINGS` | the settings button | |
| `LF_UPDATE` | the Update button, or Try again after a failure | |
| `LF_LANGUAGE` | a language was picked | its code (the game calls `i18n_use` and keeps the setting) |
| `LF_CRASH_REPORT`, `LF_CRASH_DISMISS` | the crash note's buttons | |
| `LF_LINK` | a link, a `link` button, or a news item's Read more | the address (the game opens the browser) |
| `LF_QUIT` | the quit button | |
| `LF_CUSTOM` | a `custom` button | the row's `arg` |

`button` is the key of the row that said it, when one did.

## API

| | |
| --- | --- |
| `launcher_reset(st)`, `launcher_use(st, key) -> bool`, `launcher_tick(st)`, `launcher_ready(st)` | before anything, choosing a row, once a frame (ports read, buttons follow them, the feed asked and read) |
| `launcher_system() -> System` | the same as a `ludic.base` system in `PH_PRESENT` (saves nothing) |
| `launcher_title`, `_tagline`, `_logo`, `_art`, `_background`, `_accent`, `_shade`, `_version` | the row's words and pictures (a `@Text` is a marked key: the translator makes it where it is drawn) |
| `launcher_button_count`, `_button_label`, `_button_icon`, `_button_verb`, `_button_primary`, `launcher_primary`, `launcher_press(st, i)` | the menu as shown, and a press on the i-th button |
| `launcher_link_count`, `_link_label`, `_link_icon`, `launcher_link_open(st, i)` | the links |
| `launcher_news_count`, `_news_home`, `_news_shown`, `_news_title`, `_news_body`, `_news_date`, `_news_tag`, `_news_image`, `_news_has_url`, `_news_loading`, `launcher_news_open(st, i)` | the news |
| `launcher_update_mode`, `_update_version`, `_update_progress`, `_update_eta`, `_update_error`, `launcher_update_start(st)` | the update slot (as last read; starting is a fact, only when there is something to start) |
| `launcher_crash_shown`, `_crash_summary`, `_crash_can_report`, `launcher_crash_report(st)`, `launcher_crash_dismiss(st)` | the crash slot |
| `launcher_language_count`, `_language_name`, `_language_current`, `launcher_language_pick(st, i)` | the language list |
| `launcher_panel(st)`, `launcher_open(st, LP_NEWS \| LP_LANGUAGE)`, `launcher_back(st)` | the panel over the page (`LP_HOME` when none) |

## The screen

A game shows it like any screen: `ui_show("LauncherScreen", null, 0.0, 0.0, w, h)` (or `ui_nodes` in a test),
once `launcher_tick` has run for the frame. The components sit in `ui/`, each as `Name.ludic`,
`Name.xml`, `Name.lss` and `Name.stories.lres` (the studio's UI editor previews the stories):

| Component | What it is | Takes |
| --- | --- | --- |
| `LauncherScreen` | the page: background, brand and menu left, art and news right, the footer, a panel over it | nothing (it reads the launcher's state and hands each part its share) |
| `LauncherBrand` | the logo, or the title in words, and the tagline | props `logo`, `title`, `tagline` |
| `LauncherMenu` | the buttons | prop `items` `[{label, icon, primary}]` |
| `LauncherUpdate` | the update: a newer version and its button, the bar, a failure and why, "up to date" | props `mode`, `newer`, `progress`, `eta`, `err` |
| `LauncherCrash` | "the game crashed last time", with Send a report and Dismiss; nothing while empty | props `shown`, `summary`, `can_report` |
| `LauncherNews` | news items that open out; `full` is the whole list in a panel | props `items` `[{title, body, date, tag, image, link}]`, `limit`, `full`, `loading` |
| `LauncherLanguage` | the languages, each in its own words | prop `items` `[{name, on}]` |
| `LauncherLinks` | the small links | prop `items` `[{label, icon}]` |
| `LauncherFooter` | the links, the language button, the version | props `links`, `languages`, `build` |

Each component's events call the launcher's verbs (`on press(i)` is `launcher_press`), so a
press is always a fact or a panel, never a side effect in the UI.

**Words.** The package's own words are text keys, `t('launcher.update.available', newer)` and the like
(27 of them). A game with a `lang` line copies the entries of [`lang/launcher.en.po`](lang/launcher.en.po)
into its source `.po`; the compiler holds every one to it. The game's own words are the rows' `@Text`
fields. Language names are plain text (`translate="no"`), in each language's own words.

**Theming.** Colours are variables: `--lc-accent`, `--lc-ink`, `--lc-panel`, `--lc-line`, `--lc-text`,
`--lc-muted`, `--lc-good`, `--lc-bad` and `--lc-gap`, defined in `ui/theme.lss` (imported by the
screen's sheet) and read by every part with a fallback, so one part's story looks right on its own. The
screen sets `--lc-accent` and `--lc-panel` from the row's `accent` and `shade`; a game restyles the
rest with its own sheet (`<LauncherScreen class="mine"/>` and `.mine { --lc-ink: #101820 }`), and
the layout is ordinary `.lss` in the component's own file.

## Tests

```bash
ludic test packages/ludic.launcher
```

`launcher_test` runs against a fake game (rows from a `.lres`, fake ports): the rows and colours, the menu
as the game's answers change, presses and their facts, links, language, the update's and the
crash's slots, the feed (rows then items, languages, failure, refresh, no address) and the screen's
components driven through `ludic.ui` (a press leaves a fact). `wiring_test` joins it to `ludic.update`
and `ludic.i18n`.

The screen's checks are tests like the rest: each test gets the components registered, in its own fresh states.
