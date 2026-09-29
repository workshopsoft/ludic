# ludic.lab

The visual lab: one model or one mechanic on a **plate**, photographed from fixed cameras. A lab
scene is a minimal, isolated, reproducible piece of a game - never the whole world. The plate is a
flat, lit disc 40 m across with a line every metre, a small sky of its own with the sun 40 degrees
up (one fixed hour), and a clock of frames: 60 a second, whatever the machine. Nothing else is
loaded - no terrain, no grass, no water (`r3d_plate_mode` in ludic.render3d) - so a scene starts in
about a second and takes about 120 MB resident (420 MB peak footprint with the GPU driver's share)
where a lab on a whole valley took 7.8 GB.

`module ludic_lab uses ludic_render3d, ludic_base`.

## A lab program

```ludic
import "ludic.lab"
program Lab {
  numbers float
  function probe_setup() -> void {
    lab_model(lab_plate_dir(), "probe.gltf", "probe", 0.0, 0.0, 0.5)
    lab_shot_at("front", 0.0, 0.7, 0.0, 4.0, 0.0, 12.0)
    lab_shot_at("above", 0.0, 0.5, 0.0, 7.0, 30.0, 55.0)
  }
  def LabScenes probe { setup: fn probe_setup }
  handler Boot phase Start { lab_boot() }
  handler Look phase Input { lab_input() }
  handler Draw phase Render { lab_render() }
}
```

`example/plate.ludic` is this program. Scenes are an open registry, so a game - or a package
showing its own models - adds them from its own module with `def LabScenes <name> { ... }`:

| field | |
| --- | --- |
| `setup: fn()` | build what the scene shows and name its cameras |
| `tick: fn(float)` | move it, by the lab's fixed step (1/60 s) |
| `draw: fn()` | draw what is not an actor or a scatter layer (actors and layers are drawn already) |

`R3D_SCENE=<name>` picks the scene (the first one added otherwise); an unknown name lists them.

## Running it

- **Headless** (`ludic build ... --headless`): every shot is held `lab_settle` frames (45), written
  to `build/lab/<scene>/<shot>.png`, and after the last the program quits. The headless loop reads a
  line of stdin a frame: `yes '' | head -n 20000 | R3D_SCENE=probe ./lab`.
- **In a window**: N and P step through the shots.
- `tools/lab/run.sh <lab.ludic> <scene> ...` (in the toolchain's checkout) builds the program, runs
  each scene and makes `build/lab/<scene>/sheet.png`, a contact sheet (`tools/lab/sheet.py`).

## API

| | |
| --- | --- |
| `lab_boot()`, `lab_input()`, `lab_render()` | the program's Start, Input and Render handlers |
| `lab_shot(name, x, y, z, yaw_deg, pitch_deg)` | a camera at a point, looking along yaw and pitch (degrees) |
| `lab_shot_at(name, tx, ty, tz, dist, from_deg, up_deg)` | a camera `dist` metres from a point, from a bearing (0 = from +z), `up_deg` above it, looking at it |
| `lab_shot_count()` | the cameras named so far |
| `lab_model(dir, file, node, x, z, yaw) -> Actor`, `lab_stand(a, x, z, yaw)`, `lab_ground_y(x, z)` | a glTF node stood on the plate; the plate is flat at y = 0 |
| `lab_plate_dir()` | the package's `plate/`: the disc, its sky and the probe model |
| `lab_settle(frames)`, `lab_font(dir)`, `lab_title(s)`, `lab_note(s)` | how long a shot settles; the overlay font for captions (none by default); the window's title; a line under the caption |
| `lab_scene()`, `lab_frame()`, `lab_time()` | the scene, and the lab's clock |
| `lab_ppm_to_png(ppm, png)` | a frame as a PNG (stored, not compressed) |
| `lab_png_write(path, w, h, channels, px)`, `lab_png_write_from(..., px, at)` | 8-bit pixels (1 grey, 2 grey + alpha, 3 RGB, 4 RGBA) as a PNG, the same way; `png_write.ludic` needs nothing else of the lab, so a program with a lab of its own imports it alone (`import "ludic.lab/png_write.ludic"`, state `LabPngState`) |
| `lab_px_r32f_norm`, `lab_px_rg16f`, `lab_px_rgba16f_hdr` (`png_convert.ludic`) | previews of float textures as 8-bit pixels: R32F min..max to black..white; RG16F as red and green x255, blue 0; HDR RGBA16F as x/(1+x) then sRGB, alpha dropped |

## The plate's files

`plate/` is built by `tools/lab/plate_build.py` in the toolchain's checkout and is deterministic:
`plate.gltf` (the disc), `probe.gltf` (a box with a ball on it, for looking at the light), and
`sky.hdr` (512 x 256, the sun at 40 degrees). Change the script and run it again; never edit them.

## Not here yet

- A heightfield patch for a scene that needs a slope: the plate is flat.
