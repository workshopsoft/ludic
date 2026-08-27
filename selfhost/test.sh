#!/bin/bash
# test.sh — the self-hosting suite: the compiler is correct (compiles diverse
# programs to working binaries) and self-reproducing (the bootstrap fixpoint).
set -u
cd "$(dirname "$0")/.."
CC="${LUDIC_CC:-clang}"
PASS=0; FAIL=0
ok()  { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); }

echo "== build the self-host compiler (via the C ludicc) =="
[ -x build/ludicc ] || ./build.sh >/dev/null 2>&1
./build.sh examples/snake.ludic --headless >/dev/null 2>&1 && [ -x build/ludicc ] && ok "compiler builds from the IR seed (no C)" || { bad "self-host build"; exit 1; }

echo "== the self-host compiler is correct =="
run_case() {  # name  expected
  local n="$1" exp="$2"
  ./build/ludicc "selfhost/tests/$n.ludic" > "/tmp/sh_$n.ll" 2>"/tmp/sh_$n.err" || { bad "$n: self-host errored: $(head -1 /tmp/sh_$n.err)"; return; }
  $CC "/tmp/sh_$n.ll" -o "/tmp/sh_$n" 2>/dev/null || { bad "$n: IR did not assemble"; return; }
  local got; got=$("/tmp/sh_$n" 2>/dev/null | tr '\n' ' ' | sed 's/ *$//')
  [ "$got" = "$exp" ] && ok "$n ($got)" || bad "$n: got [$got] want [$exp]"
}
run_case structs "7 9 109 2 42"
run_case slices  "0 20 361 777"
run_case control "55 4 15 1"
run_case match_bits "1 2 9 16 4 9999"
run_case fixed "2 3 0 6 1"

echo "== the self-host compiler compiles real games (vs golden output) =="
# The golden PPMs in selfhost/golden/ were produced by the original C compiler.
# The self-hosted compiler must reproduce them exactly.
game_case() {  # name  keys
  local n="$1" keys="$2"
  ./selfhost/game-build.sh build/ludicc "examples/$n.ludic" "/tmp/ludic_${n}_sh" >/tmp/gb.out 2>&1 || { bad "$n: build ($(tail -1 /tmp/gb.out))"; return; }
  printf '%s' "$keys" | "/tmp/ludic_${n}_sh" >/dev/null 2>&1; cp out.ppm "/tmp/${n}_sh.ppm"
  cmp -s "selfhost/golden/$n.ppm" "/tmp/${n}_sh.ppm" && ok "$n matches the golden render" || bad "$n: differs from golden"
}
game_case snake "ddssaawwddss"
game_case menu "ssss"
game_case chronorift "ddddwwwwaassK"

echo "== the bootstrap fixpoint (seeded from the C compiler) =="
./selfhost/bootstrap.sh >/tmp/boot.out 2>&1
if grep -q "FIXPOINT" /tmp/boot.out; then ok "gen2.ll == gen3.ll (compiler reproduces itself)"; else bad "fixpoint not reached"; cat /tmp/boot.out; fi

echo "== the C-free bootstrap (from the checked-in IR seed, no C compiler) =="
./selfhost/bootstrap-cfree.sh >/tmp/cfree.out 2>&1
if grep -q "no C compiler" /tmp/cfree.out; then ok "seed.ll rebuilds the compiler and is its own fixed point"; else bad "C-free bootstrap failed (seed stale? run ./selfhost/reseed.sh)"; cat /tmp/cfree.out; fi

echo
printf "== %d passed, %d failed ==\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
