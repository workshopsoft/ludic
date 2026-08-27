#!/bin/bash
# reseed.sh — regenerate the checked-in IR seed after a deliberate change to the
# self-host compiler. Uses the CURRENT seed (C-free) to produce the new one, so
# the C compiler is not reintroduced; falls back to the C ludicc if no seed
# builds. Always verify with ./selfhost/bootstrap-cfree.sh afterwards.
set -eu
cd "$(dirname "$0")/.."
CC="${LUDIC_CC:-clang}"
B=build/cfree; mkdir -p "$B"
FRAGS="selfhost/str.ludic selfhost/buf.ludic selfhost/io.ludic selfhost/ast.ludic
selfhost/lex.ludic selfhost/parse.ludic selfhost/parse_game.ludic selfhost/emit_core.ludic selfhost/emit_head.ludic
selfhost/emit_addr.ludic selfhost/emit_intrin.ludic selfhost/emit_intrin2.ludic selfhost/emit_math.ludic selfhost/emit_new.ludic
selfhost/emit_expr.ludic selfhost/emit_stmt.ludic selfhost/emit_ecs.ludic selfhost/emit_query.ludic selfhost/emit_spawn.ludic selfhost/emit_game.ludic selfhost/emit_machine.ludic selfhost/emit_save.ludic selfhost/emit_ui.ludic selfhost/emit_decl.ludic selfhost/main.ludic"
{ echo "game SelfHost {"; for f in $FRAGS; do cat "$f"; echo; done; echo "}"; } > "$B/selfhost.ludic"
if $CC selfhost/ludicc.seed.ll -o "$B/sh_old" 2>/dev/null; then
  # compile once with the old seed, then AGAIN with the freshly built one so the
  # seed is a fixed point of the NEW compiler, not a one-step image of the old.
  "$B/sh_old" "$B/selfhost.ludic" > "$B/step1.ll"
  $CC "$B/step1.ll" -o "$B/sh_new"
  "$B/sh_new" "$B/selfhost.ludic" > selfhost/ludicc.seed.ll
else
  echo "seed does not build; reseeding from the C ludicc"
  ./selfhost/build.sh build/ludicc "$B/sh_c"
  "$B/sh_c" "$B/selfhost.ludic" > selfhost/ludicc.seed.ll
fi
echo "reseeded: $(wc -l < selfhost/ludicc.seed.ll | tr -d ' ') lines"
