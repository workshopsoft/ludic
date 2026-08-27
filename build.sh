#!/bin/bash
# build.sh — compile a Ludic program with the self-hosted Ludic compiler.
#
# The compiler is written in Ludic (selfhost/*.ludic). It is built from the
# checked-in LLVM-IR seed (selfhost/ludicc.seed.ll) with clang alone — no C
# compiler is involved anywhere. clang then assembles the emitted IR and links
# it; a windowed build also links the hand-written platform layer (cocoa.ll).
#
#   ./build.sh examples/snake.ludic              # windowed native app
#   ./build.sh examples/snake.ludic --headless   # headless (renders out.ppm)
set -u
cd "$(dirname "$0")"
CC="${LUDIC_CC:-clang}"
mkdir -p build

# the compiler itself: assembled from the IR seed (C-free)
if [ ! -x build/ludicc ] || [ selfhost/ludicc.seed.ll -nt build/ludicc ]; then
  echo "cc: selfhost/ludicc.seed.ll -> build/ludicc  (from the IR seed, no C compiler)"
  $CC selfhost/ludicc.seed.ll -o build/ludicc || exit 1
fi

SRC=""; MODE=windowed; SAVE=0
for a in "$@"; do
  case "$a" in
    --headless) MODE=headless ;;
    --windowed) MODE=windowed ;;
    --save-temps) SAVE=1 ;;
    -*) ;;
    *) SRC="$a" ;;
  esac
done
[ -n "$SRC" ] || { echo "usage: ./build.sh <file.ludic> [--headless]"; exit 1; }
NAME="$(basename "${SRC%.ludic}")"

case "$MODE" in
  windowed)
    OUT="build/$NAME"
    echo "ludicc: $SRC -> $OUT  (Ludic-written compiler -> LLVM IR -> windowed binary)"
    build/ludicc --windowed "$SRC" > "$OUT.ll" || exit 1
    $CC -O2 "$OUT.ll" runtime/native/cocoa.ll -framework Cocoa -Wl,-rpath,@loader_path -o "$OUT" || exit 1
    [ "$SAVE" = 1 ] || rm -f "$OUT.ll"
    echo "done. run: ./$OUT   (from the repo root, so assets/ resolves)"
    ;;
  headless)
    OUT="build/${NAME}_headless"
    echo "ludicc: $SRC -> $OUT  (renders the last frame to out.ppm)"
    build/ludicc --headless "$SRC" > "$OUT.ll" || exit 1
    $CC -O2 "$OUT.ll" -o "$OUT" || exit 1
    [ "$SAVE" = 1 ] || rm -f "$OUT.ll"
    echo "done. run: printf 'ddss' | ./$OUT && open out.ppm"
    ;;
esac
