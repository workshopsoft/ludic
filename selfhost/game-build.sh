#!/bin/bash
# game-build.sh — compile a Ludic GAME with the self-hosted compiler. The
# compiler resolves the game's own `import`s and auto-splices the Ludic runtime
# (runtime/native/core.ludic + its imports), exactly as the C compiler does.
# Headless only for now (renders to out.ppm). Run from the repo root.
#   ./selfhost/game-build.sh <selfhost-bin> <game.ludic> <out-binary>
set -u
cd "$(dirname "$0")/.."
SH="$1"; GAME="$2"; OUT="$3"
CC="${LUDIC_CC:-clang}"
ERR="$(mktemp)"
"$SH" "$GAME" > "$OUT.ll" 2>"$ERR" || { echo "self-host failed:"; head -5 "$ERR"; rm -f "$ERR"; exit 1; }
# -O2 removes the dead windowing branches (is_windowed()==0) so win_* need no defs
$CC -O2 "$OUT.ll" -o "$OUT" 2>"$ERR" || { echo "link failed:"; grep -i error "$ERR" | head -5; rm -f "$ERR"; exit 1; }
rm -f "$ERR" "$OUT.ll"                 # keep only the binary
echo "built $OUT"
