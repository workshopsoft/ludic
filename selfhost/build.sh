#!/bin/bash
# build.sh — assemble the self-host compiler from its fragments and compile it
# with the given ludicc (default: the C build/ludicc).
#   ./selfhost/build.sh [ludicc] [outbin]
set -u
cd "$(dirname "$0")/.."
LC="${1:-build/ludicc}"
OUT="${2:-build/selfhost}"
mkdir -p build
FRAGS="selfhost/str.ludic
selfhost/buf.ludic
selfhost/io.ludic
selfhost/ast.ludic
selfhost/lex.ludic
selfhost/parse.ludic
selfhost/parse_game.ludic
selfhost/emit_core.ludic
selfhost/emit_head.ludic
selfhost/emit_addr.ludic
selfhost/emit_intrin.ludic
selfhost/emit_intrin2.ludic
selfhost/emit_math.ludic
selfhost/emit_new.ludic
selfhost/emit_expr.ludic
selfhost/emit_stmt.ludic
selfhost/emit_ecs.ludic
selfhost/emit_query.ludic
selfhost/emit_spawn.ludic
selfhost/emit_game.ludic
selfhost/emit_machine.ludic
selfhost/emit_save.ludic
selfhost/emit_net.ludic
selfhost/emit_ui.ludic
selfhost/emit_decl.ludic
selfhost/main.ludic"
SRC=build/selfhost.ludic
{ echo "program SelfHost {"; for f in $FRAGS; do cat "$f"; echo; done; echo "}"; } > "$SRC"
# the compiler emits IR to stdout; clang assembles and links it
"$LC" "$SRC" > "$OUT.ll" 2>/dev/null && ${LUDIC_CC:-clang} "$OUT.ll" -o "$OUT" 2>/dev/null
rc=$?; rm -f "$OUT.ll"; [ $rc -eq 0 ]
