#!/bin/bash
# bootstrap.sh — the self-hosting proof.
#
#   stage0: the C compiler (build/ludicc) compiles the self-host source  -> gen1
#   stage1: gen1 compiles the self-host source                            -> gen2
#   stage2: gen2 compiles the self-host source                            -> gen3
#   assert: gen2.ll == gen3.ll   (the compiler reproduces itself exactly)
#
# gen1 is built by a *different* compiler (the C one), so its IR legitimately
# differs; gen2 == gen3 is the fixpoint that proves independence.
set -u
cd "$(dirname "$0")/.."
CC="${LUDIC_CC:-clang}"
B=build/boot
mkdir -p "$B"
say() { printf "  %s\n" "$1"; }

# stage 0: C compiler builds the self-host compiler (also writes build/selfhost.ludic)
./selfhost/build.sh build/ludicc "$B/gen1" >/dev/null 2>&1 || { echo "FAIL: stage0 build"; exit 1; }
say "stage0: C ludicc -> gen1 (self-host compiler)"

# stage 1: gen1 compiles the self-host source to IR, assemble -> gen2
"$B/gen1" build/selfhost.ludic > "$B/gen2.ll" 2>/dev/null || { echo "FAIL: gen1 self-compile"; exit 1; }
$CC "$B/gen2.ll" -o "$B/gen2" 2>/dev/null || { echo "FAIL: gen2 assemble"; exit 1; }
say "stage1: gen1 -> gen2.ll ($(wc -l < "$B/gen2.ll" | tr -d ' ') lines) -> gen2"

# stage 2: gen2 compiles the self-host source to IR -> gen3
"$B/gen2" build/selfhost.ludic > "$B/gen3.ll" 2>/dev/null || { echo "FAIL: gen2 self-compile"; exit 1; }
say "stage2: gen2 -> gen3.ll ($(wc -l < "$B/gen3.ll" | tr -d ' ') lines)"

# the fixpoint
if cmp -s "$B/gen2.ll" "$B/gen3.ll"; then
  rm -f build/selfhost.ludic
  echo "  ✅ FIXPOINT: gen2.ll == gen3.ll — the self-hosted compiler reproduces itself"
  exit 0
else
  echo "  ❌ gen2.ll != gen3.ll"
  diff "$B/gen2.ll" "$B/gen3.ll" | head
  exit 1
fi
