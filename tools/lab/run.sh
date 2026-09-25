#!/bin/sh
# run.sh <lab.ludic> [<scene> ...]: build a ludic.lab program headless, render every shot of each
# scene to build/lab/<scene>/<shot>.png and make build/lab/<scene>/sheet.png of them.
#   LAB_NOBUILD=1  reuse build/lab_headless as it is      LUDIC=<ludic>  the CLI to build with
# With no scene it lists the program's scenes.
set -e
prog=$1
[ -n "$prog" ] || { echo "usage: run.sh <lab.ludic> [scene ...]" >&2; exit 2; }
shift
here=$(cd "$(dirname "$0")" && pwd)
LUDIC=${LUDIC:-ludic}
if [ -z "$LAB_NOBUILD" ]; then "$LUDIC" build "$prog" --headless -o build/lab_headless >/dev/null; fi
if [ $# -eq 0 ]; then echo q | R3D_SCENE=__list__ ./build/lab_headless 2>/dev/null | grep "no scene" || true; exit 0; fi
for scene in "$@"; do
  out=build/lab/$scene
  mkdir -p "$out"; rm -f "$out"/*.png "$out"/*.ppm
  # one line of stdin per frame: the headless loop ends when it runs dry
  yes '' | head -n 20000 | R3D_SCENE=$scene R3D_TEST_ROOT=lab_$scene ./build/lab_headless > "$out/run.log" 2>&1 || true
  python3 "$here/sheet.py" "$out"
done
