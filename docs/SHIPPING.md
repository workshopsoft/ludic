# Shipping a Ludic game

`ludic build` gives you a program. `ludic bundle` gives you an application.

The difference matters more than it sounds. A built binary opens its assets by a
path relative to the working directory, so it runs from the project root and
nowhere else; double-clicked it opens a Terminal window; it wears the generic
executable icon and calls itself whatever the file is called. None of that is
something you can hand to a player.

```bash
ludic pack        # every asset into one file
ludic bundle      # ...and that, the binary, an icon and the metadata, as a .app
```

## What goes in the manifest

Everything the bundler needs lives in `package.ludic`, so the command takes no
arguments:

```ludic skip
package "example.com/studio/pine-woods"
version "0.1.0"

app  name       "Pine Woods"
app  id         "com.example.pine-woods"
app  icon       "assets/app/icon.png"
app  splash     "assets/app/splash.png"
app  splash_bg  "#0d1b2a"
app  category   "public.app-category.adventure-games"
app  copyright  "(c) 2026 Example Studio"
app  min_macos  "11.0"

pack "assets"
```

| key | what it does | default |
| --- | --- | --- |
| `app name` | the name under the icon, spaces and all | the package's name |
| `app id` | the bundle identifier | derived from the package path |
| `app version` | `CFBundleVersion` | the manifest's `version` |
| `app icon` | a source PNG, ideally 1024x1024 | no icon |
| `app splash` | shown from process start until the game says otherwise | no splash |
| `app splash_bg` | `#RRGGBB` painted behind the splash | black |
| `app category` | `LSApplicationCategoryType` | omitted |
| `app copyright` | `NSHumanReadableCopyright` | omitted |
| `app min_macos` | `LSMinimumSystemVersion` | `11.0` |
| `app sign` | a codesigning identity | ad-hoc (`-`) |
| `app out` | where to write the bundle | `build/<name>.app` |
| `pack` | an asset root, repeatable | `assets/` if it exists |
| `maps` | where the maps' own tables are, one directory a map (`@PerMap` registries, LANGUAGE.md) - the compiler builds it into the program and `ludicc --check` reads every map under it | `assets/maps` |
| `lang` | the languages' directory and the source language (`lang "assets/lang" en`): the compiler checks every text key against `<dir>/<source>.po` (LANGUAGE.md, Text keys) | none: no key is checked |

Only `app name` is worth setting deliberately. The identifier is derived from the
package path when you omit it - `example.com/studio/pine-woods`
becomes `com.example.pine-woods` - but it is worth pinning, because Launch
Services keys the Dock, saved window state and permissions off it, and two apps
sharing one identifier is a class of bug that looks like haunting.

## The asset pack

`ludic pack` writes a `.lpak`: a header, an entry table sorted by name, a name
heap and the blobs. Entries are **stored, not compressed** - PNG, JPEG and glTF
binary arrive compressed already, and a decompressor on the load path would
spend CPU to make the file no smaller.

Nothing about how the game is written changes. This line:

```ludic skip
let model = gltf_load("assets/kit/hiker", "hiker.gltf", "hiker")
```

reads a file during development and a run of bytes inside
`Pine Woods.app/Contents/Resources/game.lpak` once shipped, and cannot tell
which. That works because the pack is spliced in at `file_open`, the one place
every asset in a Ludic program comes through - `gltf_load`, `tex_load`,
`Audio.load`, `Fs.read_text` and the renderer's own shader loads all bottom out
there. `Fs.exists` and `Fs.size` consult the packs too, so a game that guards a
load with `Fs.exists` keeps finding its assets once they are packed.

The pack is `mmap`'d rather than read, so 165 MB of terrain costs one syscall at
startup and pages in only what the game touches.

```bash
ludic pack --list build/pine-woods.lpak     # what is in it
ludic pack --verify build/pine-woods.lpak   # re-hash every entry
```

### Keeping things out: `.packignore`

A pack root goes in wholesale, which is the right default and the reason a game only
has to write `pack "assets"`. It also means everything the game does *not* open ships
with it — the preview renders a model pipeline leaves beside its meshes, the
intermediate a texture bake writes and never reads again, the `.blend` the `.gltf` came
out of. Nothing errors and nothing looks wrong; the app is just bigger than the game.

Put a `.packignore` beside the assets and those stop shipping:

```
# what the builders leave behind
preview/                 # a directory, at any depth
*.blend                  # a name, at any depth
/scratch                 # only at this file's own level
**/tmp                   # any depth, said explicitly
textures/*_intermediate.png
!textures/keep_intermediate.png   # ...except this one
```

The rules are **gitignore's**, because that is the file everyone already knows:

- Blank lines and `#` comments are skipped; write `\#` or `\!` for a literal leader.
- A pattern with **no** slash matches a name at any depth. A pattern **with** one is
  anchored to the directory holding the `.packignore`.
- A trailing `/` means directory-only: `preview/` never matches a *file* called
  `preview`.
- `*` and `?` stop at a `/`; `**` crosses one. `a/**/b` matches `a/b` too.
- `[abc]`, `[a-z]` and `[!abc]` are character classes.
- `!` re-includes, and within one file the **last** matching line wins.
- A `.packignore` deeper in the tree beats a shallower one — a kit can keep something
  the project excludes everywhere else.
- A file under an ignored **directory** cannot be re-included, exactly as in git.
  Ignore the files rather than the directory when that is what you meant.

Two rules of its own, because a pack is not a working tree:

- **`.packignore` is never packed.** Nothing reads one at run time, and `--no-ignore`
  does not bring it back either.
- **It applies to your roots, not to a package's.** The resources a package contributes
  to a bundle — the renderer's shaders above all — are added after your roots are
  gathered, so a stray `*.frag` in a game's ignore file cannot quietly un-ship them.

`ludic pack` says what it left out, and `--no-ignore` packs everything so you can see
what a rule is costing:

```bash
ludic pack                  # packed 216 files, 358377 KiB, 164 skipped by .packignore -> ...
ludic pack --no-ignore      # packed 380 files, 390820 KiB -> ...
```

`ludic bundle` gathers assets the same way, so the two agree by construction.

### More than one pack

`Contents/Resources/packs.index` is a plain list, and the order is load-bearing:

```
pack base.lpak
pack patch.lpak
```

Packs mount in the order listed and a later one **shadows** an earlier one, so a
patch or an add-on replaces individual files without rewriting the base pack. An
override is always a pack, never a loose file: the pack is searched before the
filesystem, so a stray or corrupt file cannot shadow a shipped asset.

### Where a bundled game saves

A `.app` launched from Finder starts with its working directory at `/`, where
nothing is writable, so `packs.index` also carries:

```
home Pine Woods
```

and the runtime moves the process to `~/Library/Application Support/Pine Woods`
before `main`. Reads come out of the pack; writes land somewhere real and
per-user. A game's save code needs no change and no platform knowledge.

## The splash

A game that loads 165 MB spends a noticeable moment doing it, and until it is
done there is nothing on screen - the window is not open yet, because opening it
is part of what the game does once it has something to draw. From the outside
that is indistinguishable from a launch that failed.

The splash is raised from a constructor that runs **before `main`**, so it
appears while the process is still starting rather than after the expensive
part, which is the only ordering that helps. It is a borderless window holding
the game's own artwork, read out of the pack like any other asset.

Nothing hides it automatically. Only the game knows when its first real frame is
ready, so the game says so:

```ludic skip
App.splash_hide()
```

## During development

None of this is in the way. Without a `packs.index` beside the executable -
which is every `ludic run` - nothing mounts, no directory change happens, no
splash appears, and every open goes to the filesystem exactly as before.
Packing is a shipping step, and it is invisible until you ship.

### Renderer switches in a shipped game

`ludic.render3d` has about seventy `R3D_*` environment switches - debug views
(`R3D_WIRE`, `R3D_DEBUG*`, `R3D_LODDBG`, ...), feature kills (`R3D_NOSHADOW`,
`R3D_NOTERRAIN`, ...), file writers (`R3D_DUMP_*`, `R3D_DRAWSTATS_CSV`, ...),
hardware fakes (`R3D_CAPS`, `R3D_FORCE`, `R3D_GFX`) and the Windows feature
overrides (`R3D_DLSS*`, `R3D_REFLEX`, `R3D_HDR`, `R3D_MESH_GRASS`). They are
developer tools, so a player cannot trip them by accident:

- a **headless** build always honours them - tests, benchmarks and frame dumps
  work exactly as before;
- a **windowed** build ignores every one of them unless `R3D_DEV` is set to
  anything but `0`.

```bash
R3D_DEV=1 R3D_WIRE=1 ./MyGame.app/Contents/MacOS/MyGame
```

A game that has its own switches should gate them the same way. Inside render3d,
read a new switch with `r3d_env_has("R3D_FOO")` / `r3d_env("R3D_FOO")`, never
`Os.has_env` / `Os.env`.

## Signing and distribution

`ludic bundle` ad-hoc signs the result. On Apple silicon that is not optional
the way it was on Intel: an unsigned binary is killed outright rather than
merely warned about, so without a signature the app will not run even on the
machine that built it.

An ad-hoc signature is **not** enough to get the app past Gatekeeper on someone
else's Mac. That needs a Developer ID certificate and notarisation, which are
Apple's, not Ludic's:

```ludic skip
app sign "Developer ID Application: Your Name (TEAMID)"
```

```bash
ludic bundle
xcrun notarytool submit "build/Pine Woods.app" --keychain-profile NOTARY --wait
xcrun stapler staple "build/Pine Woods.app"
```

## Releasing: `ludic release`

`ludic bundle` makes the thing you give someone; `ludic release` puts a version of it where installed
copies find it, with [Velopack](https://velopack.io)'s CLI, `vpk` (`dotnet tool install -g vpk`). It
reads `release` lines from `package.ludic`, packs the bundle into Velopack's packages (an installer
or portable zip, the full package, a delta against the last release) and uploads them with the feed.

```ludic skip
release id             "PineWoods"
release title          "Pine Woods"
release authors        "Example Studio"
release channel        osx "osx"
release channel        win "stable"
release feed           "https://dl.example.com"
release keep           12
release notes          "build/release-notes.md"
release entitlements   "tools/release/app.entitlements"
release sign           "Developer ID Application: Your Name (TEAMID)"
release notary_profile "my-notary-profile"
release upload         s3 "my-bucket" "https://<account>.r2.cloudflarestorage.com"
```

| line | what it does | default |
| --- | --- | --- |
| `release id` | Velopack's pack id (`--packId`); required | none |
| `release title`, `release authors` | `--packTitle`, `--packAuthors` | `app name`; vpk's own |
| `release channel <os> "<name>"` | the channel for `osx`, `win` or `linux` (`--channel`) | the OS name |
| `release feed "<https url>"` | where the game's updater looks. vpk does not use it; it is shown in the plan | none |
| `release keep <n>` | releases the feed keeps (`--keepMaxReleases`) | vpk's |
| `release notes "<file>"` | release notes, Markdown (`--releaseNotes`) | none |
| `release entitlements "<file>"` | macOS: `--signEntitlements` (a file named `*.entitlements`, with no XML comment) | vpk's .NET defaults |
| `release sign "<identity>"` | macOS: `--signAppIdentity`. The line with `""` (or no value) takes the keychain's first `Developer ID Application` identity. No line at all packs unsigned | unsigned |
| `release notary_profile "<name>"` | macOS: `--notaryProfile`, a `xcrun notarytool store-credentials` profile; vpk notarizes and staples before it packages | not notarized |
| `release upload s3 "<bucket>" "<endpoint>"` | where `vpk download s3` and `vpk upload s3` go (S3, R2, anything S3-shaped); the endpoint may be `""` for AWS itself | no upload |
| `release dir`, `release exe`, `release icon` | the folder to pack, its main executable and `--icon` | macOS: `app out` or `build/<name>.app`; else `build/<name>`; the app name (`.exe` on Windows); Windows: `app icon` if it is an `.ico` |

**Credentials are never in the manifest.** They come from `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` in the environment, or `--key-id` and `--secret` on the command line.

```bash
ludic bundle                          # the .app the release packs
ludic release --dry-run               # the exact commands, secrets redacted; runs nothing
ludic release --dry-run --json        # the same plan as JSON, for an editor
ludic release [--os osx|win|linux]    # run them: stops at the first failure
```

The steps, in order: `clean` (a fresh `build/releases-<os>`), `download` (`vpk download s3`: the
previous release, so vpk can make a delta; a first release has none and this step may fail),
`pack` (`vpk pack --packId .. --packVersion <app version, else the manifest's version> --packTitle ..
--packDir .. --mainExe .. --channel .. --outputDir ..`, and on macOS `--noInst --signAppIdentity
--signEntitlements --notaryProfile`), `upload` (`vpk upload s3 --bucket .. --endpoint .. --keyId ..
--secret .. --channel .. --keepMaxReleases ..`). `--os` defaults to the host. A `release` with no
`release upload` line makes the packages and stops there.

`--dry-run --json` prints one object: `os`, `dry_run`, `pack_id`, `version`, `title`, `channel`,
`feed`, `bucket`, `pack_dir`, `pack_dir_exists`, `output_dir`, `credentials` (`"env"`, `"flags"` or
`"missing"`), `vpk` (the path found, or `null`), `problems` (what stops a release: no `release id`,
no Developer ID; the exit code is 1 when there are any), `warnings` (what a dry run can say and a real
run refuses: no `vpk`, no bundle yet, no credentials, unsigned) and `steps`, each `{"id", "title",
"optional", "command"}` with the credentials shown as `<redacted>`.

What it does not do: build the bundle, write a changelog, tag, build a website, purge a cache, or
reach another machine. Those are your release process around it. A project's own `script "release"`
keeps running as `ludic release`, so existing ones are unaffected.

The game's own updater (`ludic.update`'s `UpdateConfig.feed` and `app_id`) is configured in game code:
no value in `package.ludic` reaches the program at build time (only `app name`, as the window title),
so write the same feed and pack id in both places.

## Crash reports and symbols

A shipped game that dies should leave something behind that a developer can read. Ludic's part of that
is two things: a **crash record** the game writes when it dies, and the **symbols** of the build it died
in. The studio joins them (it turns the addresses in the record into function names and reports them to
PostHog's error tracking as `$exception` events); PostHog itself cannot read a minidump or a Windows
PDB, so the joining is ours.

### The record

`ludic.crash` ([its README](../packages/ludic.crash/README.md) has the record format, field by field)
installs the runtime's handler at the start. It catches `SIGSEGV`, `SIGBUS`, `SIGILL`, `SIGFPE`,
`SIGABRT` and `SIGTRAP` on macOS (an alternate stack, so a stack overflow is caught too) and unhandled
exceptions on Windows, and writes `crash-<unix time>-<pid>.lcr` into the game's crash folder: JSON
lines with the build, the version, the OS, the signal or exception, the fault address, the registers,
the backtrace as raw return addresses, and the images loaded (path, base, size, and the `LC_UUID` or
the CodeView GUID and age that names their symbols). Then the signal is raised again, so the OS and a
launcher's `Process.poll` see the crash as they always did (`128 + signal`; on Windows the NTSTATUS).

```ludic skip
let c = new CrashConfig
c.dir = Path.join(save_root, "crashes")
c.app = "Pine Woods"
c.version = "0.1.0"
crash_config(crash_st, c)
crash_start(crash_st)            # before anything can crash; answers how many records wait from last time
```

The handler runs inside a crash, so it allocates nothing and takes no lock, and it formats the record by
hand; the backtrace is a scan of the crashing thread's stack for return addresses, because ludicc's
functions keep no frame-pointer chain. `crash_win.ll` is the same on Windows, written and compiled
without a Windows machine. The next start finds the records (`crash_pending`), keeps the newest
`keep_n`, and offers each to the game to show ("the game crashed last time") and to send through
`ludic.telemetry` as a raw event. **Consent**: with the player's switch off (`CrashWorld.consent`)
a record stays a local file and nothing is sent.

A build that calls `ludic.crash` links the handler (`runtime/native/crash.ll`, or `crash_win.ll` on
Windows); any other build does not contain it.

### The symbols

`ludic build` (windowed) and `ludic bundle` keep the symbols of what they built, **beside the output and
never inside the bundle**, under the id the linker stamped into the binary:

```
build/symbols/<id>/meta.json        id, os, arch, kind, name, file, binary, version, size
build/symbols/<id>/<name>.dSYM      macOS: dsymutil's bundle, keyed by the binary's LC_UUID
build/symbols/<id>/<name>.pdb       Windows: the PDB the link wrote, keyed by GUID and age
```

The shipped binary is exactly what it was before (nothing is stripped or added; the bundle is the same
size); its `LC_UUID` is what ties it to its dSYM. On Windows the link is asked for a PDB
(`-Wl,/DEBUG` through `LUDIC_CC`; set `LUDIC_NO_SYMBOLS=1` to skip keeping symbols on either OS), and
the id is the GUID (without dashes) and the age in hex, the key a symbol server uses. The IR carries no
DWARF, so a dSYM holds the symbol table - function names, not lines.

```bash
ludic symbols              # 8545D571-AC52-...  macos/arm64  dsym  pine-woods 0.1.0  build/symbols/8545D571-.../pine-woods.dSYM
ludic symbols --json       # the same, for the studio to upload and store
```

`--json` prints one object: `dir` (where it looked, `build/symbols`; `--dir DIR` names another) and
`symbols`, a list of `{"id", "os", "arch", "kind", "name", "file", "binary", "version", "size"}` -
`kind` is `"dsym"` or `"pdb"`, `file` is relative to `<dir>/<id>/`, `binary` is the executable they
belong to, `size` is bytes. It is an empty list when there are none. Each build adds its own id next
to the others, so a release's symbols outlive the next build - until `ludic clean`, which removes
`build/` with them: upload first.

## The bundle it makes

```
Pine Woods.app/
  Contents/
    Info.plist                 the metadata Finder, the Dock and Launch Services read
    PkgInfo                    the eight bytes that predate Info.plist and are still read
    MacOS/Pine Woods          the game
    Resources/
      AppIcon.icns             every size macOS asks for, from one source PNG
      game.lpak                every asset the game opens
      packs.index              what to mount, where to save, what to show at boot
```
