#!/bin/bash
# test.sh — the regression suite. The compiler is now written in Ludic
# (selfhost/) and built from a checked-in LLVM-IR seed with clang; there is no C
# compiler in the repo. This suite proves the compiler builds from the seed,
# compiles every example to the byte-exact golden render, self-hosts to a
# fixpoint, and rebuilds itself with no C compiler.
set -u
cd "$(dirname "$0")"
PASS=0; FAIL=0
ok()  { printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); }

echo "== the compiler is written in Ludic, not C =="
if [ -e compiler ] || ls compiler/*.c >/dev/null 2>&1; then bad "compiler/ C sources still present"
else ok "no C compiler in the repo (compiler/ removed; the compiler is selfhost/*.ludic)"; fi
CLEFT=$(find tools -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
ok "the only C left is the editor tooling ($CLEFT files: ludic-fmt, ludic-lsp)"

echo "== the compiler builds from the IR seed (no C compiler) =="
rm -f build/ludicc
if ./build.sh examples/snake.ludic --headless >/dev/null 2>&1 && [ -x build/ludicc ]; then
  ok "clang selfhost/ludicc.seed.ll -> build/ludicc"
else bad "compiler did not build from the seed"; fi

echo "== every example compiles to its golden render =="
gcase() {  # name  keys
  local n="$1" keys="$2"
  ./selfhost/game-build.sh build/ludicc "examples/$n.ludic" "/tmp/ludic_${n}_t" >/tmp/gc.out 2>&1 || { bad "$n: build ($(tail -1 /tmp/gc.out))"; return; }
  printf '%s' "$keys" | "/tmp/ludic_${n}_t" >/dev/null 2>&1
  cmp -s "selfhost/golden/$n.ppm" out.ppm && ok "$n renders the golden frame" || bad "$n: render differs from golden"
}
gcase snake "ddssaawwddss"
gcase menu "ssss"
gcase chronorift "ddddwwwwaassK"

echo "== self-hosting and the bootstrap fixpoints =="
./selfhost/test.sh >/tmp/sh.out 2>&1
if grep -q "gen2.ll == gen3.ll" /tmp/sh.out; then ok "the compiler reproduces itself (fixpoint)"; else bad "fixpoint"; fi
if grep -q "no C compiler" /tmp/sh.out; then ok "the compiler rebuilds itself from the seed, C-free"; else bad "C-free bootstrap"; fi
CORR=$(grep -c PASS /tmp/sh.out)
ok "self-host suite: $CORR checks passed (see ./selfhost/test.sh)"

echo "== documented syntax stays compilable (guards against spec/compiler drift) =="
# Compiles a feature example end-to-end (parse -> lower -> link). qdecl exercises
# the `query (vars) [terms] where ...` clause in a system SIGNATURE.
qsmoke() {  # name
  local n="$1"
  if ./selfhost/game-build.sh build/ludicc "examples/$n.ludic" "/tmp/ludic_${n}_s" >/tmp/qs.out 2>&1; then
    ok "$n compiles (signature-query desugars to S_QUERY)"
  else bad "$n: $(tail -1 /tmp/qs.out)"; fi
}
qsmoke qdecl
# The annotation DSL: @Queries desugars to a query, @Computed inlines a derived
# field, @OnSpawn runs a constructor, @Handles parses. Check the composite output.
if ./selfhost/game-build.sh build/ludicc examples/annotations.ludic "/tmp/ludic_ann" >/tmp/ann.out 2>&1 \
   && [ "$(/tmp/ludic_ann </dev/null | tr '\n' ' ')" = "3 25 0 0 " ]; then
  ok "annotations.ludic (@Queries / @Computed / @OnSpawn / @Handles)"
else bad "annotations: $(tail -1 /tmp/ann.out)"; fi
# Lifecycle hooks fire in timeline order: @OnStart @OnAttach @OnSpawn @OnDespawn @OnQuit.
if ./selfhost/game-build.sh build/ludicc examples/lifecycle.ludic "/tmp/ludic_life" >/tmp/life.out 2>&1 \
   && [ "$(/tmp/ludic_life </dev/null | tr '\n' ' ')" = "1 700 50 950 2 " ]; then
  ok "lifecycle.ludic (@OnStart/@OnAttach/@OnSpawn/@OnDespawn/@OnQuit in order)"
else bad "lifecycle: $(tail -1 /tmp/life.out)"; fi
# enable/disable at property (with @OnDisable/@OnEnable), model, and query scopes.
if ./selfhost/game-build.sh build/ludicc examples/toggle.ludic "/tmp/ludic_tog" >/tmp/tog.out 2>&1 \
   && [ "$(/tmp/ludic_tog </dev/null | tr '\n' ' ')" = "6 0 7 1 0 " ]; then
  ok "toggle.ludic (enable/disable + @OnDisable/@OnEnable across property/model)"
else bad "toggle: $(tail -1 /tmp/tog.out)"; fi
# --- Toolchain-agent CLI smoke tests append below this line ---
echo "== self-hosted front-end binaries (ludicc / ludic) =="
# The two commands are one multi-call native binary built from the seed with
# clang alone. ludicc compiles; ludic compiles-and-runs. Each drives clang via
# the os_system intrinsic — no shell wrapper in between.
if ./build-cli.sh >/tmp/cli.out 2>&1 && [ -x ./ludicc ] && [ -x ./ludic ]; then
  ok "build-cli.sh builds ./ludicc and ./ludic from the seed (clang-only)"
else bad "build-cli.sh: $(tail -1 /tmp/cli.out)"; fi

# ludicc -o drives clang to a native binary; a game links windowed by default.
if ./ludicc examples/snake.ludic -o /tmp/cli_snake >/tmp/cli.out 2>&1 \
   && file /tmp/cli_snake 2>/dev/null | grep -q "Mach-O"; then
  ok "ludicc app.ludic -o bin  ->  native executable"
else bad "ludicc -o: $(tail -1 /tmp/cli.out)"; fi

# --emit-llvm stops at the IR.
if ./ludicc examples/snake.ludic --emit-llvm -o /tmp/cli_snake.ll >/tmp/cli.out 2>&1 \
   && head -1 /tmp/cli_snake.ll | grep -q "LLVM IR"; then
  ok "ludicc --emit-llvm  ->  LLVM IR"
else bad "ludicc --emit-llvm: $(tail -1 /tmp/cli.out)"; fi

# ludic compiles, runs, and forwards the program's exit code.
printf 'entry { os_exit(42) }\n' > /tmp/cli_exit.ludic
./ludic /tmp/cli_exit.ludic >/tmp/cli.out 2>&1
if [ "$?" -eq 42 ]; then ok "ludic app.ludic  ->  compiles, runs, forwards exit code"
else bad "ludic run: expected exit 42, got $? ($(tail -1 /tmp/cli.out))"; fi

echo
printf "== %d passed, %d failed ==\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
