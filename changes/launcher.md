bump: minor
type: feat
**ludic.launcher.** A generic first screen for any game: `LauncherScreen` and its parts (brand, menu,
update, crash slot, news, language, links, footer), each a `ludic.ui` component with `.lss` and
`.stories.lres` for the studio's UI editor. What it says and offers is data the game fills in a `.lres`
(`Launchers`, `LauncherButtons`, `LauncherLinks`, `LauncherNews`: title, `@Asset("png")` logo, art and
background, buttons as rows with verbs, links, a news feed address or rows); what it asks of the game is
`LauncherWorld` (save, update, language and crash answers, all with defaults) and `LauncherNet`; what the
player did comes out as `LauncherFact`s. The "crashed last time" slot is a port for ludic.crash or the
game to fill. Themeable through `--lc-*` variables; its own words are keys (`lang/launcher.en.po`).
