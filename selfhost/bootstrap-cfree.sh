#!/bin/bash
# bootstrap-cfree.sh — rebuild the self-hosted compiler with NO C compiler.
#
# The C `ludicc` is retired to a one-time seed: selfhost/ludicc.seed.ll is the
# self-host compiler's own LLVM IR, a proven fixed point. From it plus clang
# (an IR assembler, the same floor Rust and Swift stand on) the compiler
# rebuilds itself and reproduces its own IR — the C source is never invoked.
#
#   seed.ll --clang-->  sh_seed
#   sh_seed  compiles selfhost.ludic  -> out.ll
#   assert   out.ll == seed.ll        (the seed is a true fixed point)
set -u
cd "$(dirname "$0")/.."
CC="${LUDIC_CC:-clang}"
B=build/cfree
mkdir -p "$B"

# assemble the compiler straight from the checked-in seed — no C involved
$CC selfhost/ludicc.seed.ll -o "$B/sh_seed" 2>/dev/null || { echo "FAIL: assemble seed"; exit 1; }
echo "  seed.ll --clang--> sh_seed   (no C compiler used)"

# regenerate the concatenated source the same way build.sh does (pure shell)
FRAGS="selfhost/str.ludic selfhost/buf.ludic selfhost/io.ludic selfhost/ast.ludic
selfhost/lex.ludic selfhost/parse.ludic selfhost/parse_game.ludic selfhost/emit_core.ludic selfhost/emit_head.ludic
selfhost/emit_addr.ludic selfhost/emit_intrin.ludic selfhost/emit_intrin2.ludic selfhost/emit_math.ludic selfhost/emit_new.ludic
selfhost/emit_expr.ludic selfhost/emit_stmt.ludic selfhost/emit_ecs.ludic selfhost/emit_query.ludic selfhost/emit_spawn.ludic selfhost/emit_game.ludic selfhost/emit_machine.ludic selfhost/emit_save.ludic selfhost/emit_ui.ludic selfhost/emit_decl.ludic selfhost/main.ludic"
{ echo "program SelfHost {"; for f in $FRAGS; do cat "$f"; echo; done; echo "}"; } > "$B/selfhost.ludic"

# the seed-built compiler compiles its own source
"$B/sh_seed" "$B/selfhost.ludic" > "$B/out.ll" 2>/dev/null || { echo "FAIL: seed compiler self-compile"; exit 1; }
echo "  sh_seed compiles selfhost.ludic -> out.ll ($(wc -l < "$B/out.ll" | tr -d ' ') lines)"

if cmp -s "$B/out.ll" selfhost/ludicc.seed.ll; then
  echo "  ✅ out.ll == seed.ll — the compiler rebuilds itself with no C compiler"
  exit 0
else
  echo "  ❌ out.ll != seed.ll (seed is stale — regenerate with ./selfhost/reseed.sh)"
  diff "$B/out.ll" selfhost/ludicc.seed.ll | head
  exit 1
fi
