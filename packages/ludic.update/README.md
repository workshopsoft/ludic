# ludic.update

A game installed by [Velopack](https://velopack.io) updating itself, a frame at a time, with
nothing on screen but the game's own panel. Uses [`ludic.base`](../ludic.base/README.md) and
nothing else.

```ludic
import "ludic.update"
```

Two halves:

- **Is there a newer version?** `<feed>/latest.json` (`{"version": "1.2.0", "notes": {"en":
  [...], "tr": [...]}}`) asked once and polled a frame at a time, so a slow or absent network
  costs the frame nothing - it simply never says there is one.
- **Installing it.** Velopack's own feed (`releases.win.json`, `releases.osx.json`: every
  package with its version, type, size and SHA-256), then the plan - the chain of deltas when
  the installed full package is on disk, no delta is missing and they weigh less than the full
  one; the newest full package otherwise - then each package streamed into the packages folder
  with its bytes on the bar, its SHA-256 by a child (`Get-FileHash` on Windows, `shasum`
  elsewhere) so the frame keeps drawing, `Update patch` per delta, and `Update apply --waitPid
  <this>`. On `UPDATE_APPLYING` the game exits; Velopack waits for it, swaps the install and
  starts the new version.

What differs on macOS is where things live: the `.app` is the install, `UpdateMac` sits beside
the binary in `Contents/MacOS`, and the packages must be OUTSIDE the bundle (`mac_packages`) -
a bundle is read-only, and `apply` cannot replace a directory it is reading a package out of.
A package's name always comes from the feed (Velopack puts the channel in a macOS name), and a
translocated Mac app (still where it was downloaded) is "not installed".

The package never words anything: a step, an error and a pace are numbers and codes, and the
game says them in its own language.

## Config and ports

```ludic
property UpdateConfig {
  feed, app_id, version        # the release bucket, Velopack's pack id, this build's version
  latest ("latest.json")
  root, packages               # outright (a stand-in install, for a test); "" works them out
  mac_packages                 # where packages go on macOS
  scratch                      # where a hash is written
}
port UpdateWorld { platform, exe, pid, now_ms }                   # unbound: Os and the wall clock
port UpdateNet { get, download, poll, text, received, free }      # unbound: Http
port UpdateProc { spawn, poll, free }                             # unbound: Process
```

Every member has the runtime as its default; a game binds only what it wants to replace (a finer
clock for the pace), and a test binds fakes.

## API

| | |
| --- | --- |
| `update_config(c)` | before anything else |
| `update_check_tick(show_current)`, `update_ask_state()`, `update_shown()`, `update_fresh()`, `update_latest()`, `update_notes(lang)` | the newest version: `UPDATE_ASKING`, `_NONE`, `_NEWER`, `_CURRENT` (the version being played, kept only with `show_current`); its notes in a language, else English |
| `update_start() -> bool`, `update_tick()` | the Update button (false, and `UPDATE_ERR_NOT_INSTALLED`, on a copy Velopack did not install), then once a frame |
| `update_state()`, `update_busy()`, `update_failed()`, `update_working()`, `update_error()` | `UPDATE_IDLE`, `_FEED`, `_FETCH`, `_CHECK`, `_PATCH`, `_APPLY`, `_FAILED`; working is a check or a patch (no fraction: sweep the bar); the error is an `UPDATE_ERR_*` |
| `update_progress()`, `update_received()`, `update_file_received()`, `update_file_size()`, `update_eta_seconds()`, `update_step_seconds()` | the bar (0..1000 over every byte of the plan), the bytes, the time left at an eased pace (-1 until known), the seconds a check or patch has run |
| `update_index()`, `update_file()`, `update_version_at()`, `update_package_count()`, `update_target()`, `update_total_bytes()`, `update_plan_file(i)`, `update_plan_is_delta(i)`, `update_plan_version(i)` | the plan and where in it |
| `update_plan(feed) -> bool` | the plan from a parsed feed, outright |
| `update_facts() -> Queue<UpdateFact>` | `{ what, error, target, packages, bytes }`: `UPDATE_STARTED`, `UPDATE_STOPPED`, `UPDATE_APPLYING` (exit now) |
| `update_newer(a, b)`, `update_is_install_hook()`, `update_installed()`, `update_translocated()`, `update_dir()`, `update_root()`, `update_packages()`, `update_open(url)` | versions compared a number at a time; Velopack's `--veloapp-*` hooks (exit at once); the install's layout; a page in the browser |
| `update_reset()` | back to before anything (tests) |

## Tests

```bash
ludic build packages/ludic.update/tests/update_test.ludic --headless -o /tmp/update_test && /tmp/update_test
```

A fake network, fake children and a stand-in root in the temp directory: the notes, the plan both
ways, the whole package and the delta chain end to end, a wrong hash, a failed download and a
package already on disk.
