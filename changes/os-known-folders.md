bump: patch
type: fix
**`Os.save_dir` / `Os.config_dir` / `Os.cache_dir` follow the platform.** They were the
macOS layout everywhere, so a game built on Linux wrote its saves to
`~/Library/Application Support` — a directory that means nothing there. Naming the
right directory is the entire reason a program calls these instead of building a path.

| | macOS | Linux |
| --- | --- | --- |
| `save_dir` | `~/Library/Application Support/<app>` | `$XDG_DATA_HOME` or `~/.local/share/<app>` |
| `config_dir` | `~/Library/Application Support/<app>` | `$XDG_CONFIG_HOME` or `~/.config/<app>` |
| `cache_dir` | `~/Library/Caches/<app>` | `$XDG_CACHE_HOME` or `~/.cache/<app>` |

An XDG variable that is set but empty falls back to the default, as the spec requires.
macOS is unchanged to the byte — `save_dir` and `config_dir` stay the same directory
there, because Apple's home for a config file that is not an `NSUserDefaults` plist is
Application Support too, and a shipped game's settings must not move out from under it.
On Linux XDG separates the two and so does this.

One consequence worth stating plainly: a game already shipped on Linux was writing to
the old macOS-shaped path, and this moves it. Those files are not migrated for you —
they are wherever `~/Library/Application Support/<app>` ended up on that machine, and a
game that has Linux players should move them once on startup.
