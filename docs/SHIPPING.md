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
package "git.workshopsoft.io/workshopsoft/maroon-lake"
version "0.1.0"

app  name       "Maroon Lake"
app  id         "io.workshopsoft.maroon-lake"
app  icon       "assets/app/icon.png"
app  splash     "assets/app/splash.png"
app  splash_bg  "#0d1b2a"
app  category   "public.app-category.adventure-games"
app  copyright  "(c) 2026 Workshopsoft"
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

Only `app name` is worth setting deliberately. The identifier is derived from the
package path when you omit it - `git.workshopsoft.io/workshopsoft/maroon-lake`
becomes `io.workshopsoft.maroon-lake` - but it is worth pinning, because Launch
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
`Maroon Lake.app/Contents/Resources/game.lpak` once shipped, and cannot tell
which. That works because the pack is spliced in at `file_open`, the one place
every asset in a Ludic program comes through - `gltf_load`, `tex_load`,
`Audio.load`, `Fs.read_text` and the renderer's own shader loads all bottom out
there. `Fs.exists` and `Fs.size` consult the packs too, so a game that guards a
load with `Fs.exists` keeps finding its assets once they are packed.

The pack is `mmap`'d rather than read, so 165 MB of terrain costs one syscall at
startup and pages in only what the game touches.

```bash
ludic pack --list build/maroon-lake.lpak     # what is in it
ludic pack --verify build/maroon-lake.lpak   # re-hash every entry
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
home Maroon Lake
```

and the runtime moves the process to `~/Library/Application Support/Maroon Lake`
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
xcrun notarytool submit "build/Maroon Lake.app" --keychain-profile NOTARY --wait
xcrun stapler staple "build/Maroon Lake.app"
```

## The bundle it makes

```
Maroon Lake.app/
  Contents/
    Info.plist                 the metadata Finder, the Dock and Launch Services read
    PkgInfo                    the eight bytes that predate Info.plist and are still read
    MacOS/Maroon Lake          the game
    Resources/
      AppIcon.icns             every size macOS asks for, from one source PNG
      game.lpak                every asset the game opens
      packs.index              what to mount, where to save, what to show at boot
```
