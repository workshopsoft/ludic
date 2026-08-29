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
# a @Queries annotation with a per-property constraint and an `on:` model tag.
qsmoke() {  # name
  local n="$1"
  if ./selfhost/game-build.sh build/ludicc "examples/$n.ludic" "/tmp/ludic_${n}_s" >/tmp/qs.out 2>&1; then
    ok "$n compiles (@Queries desugars to S_QUERY)"
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
# String operators: ==/!= compare by content, + concatenates (str_* prelude).
if ./selfhost/game-build.sh build/ludicc examples/strings.ludic "/tmp/ludic_str" >/tmp/str.out 2>&1 \
   && [ "$(/tmp/ludic_str </dev/null | tr '\n' ' ')" = "1 2 3 4 5 6 7 8 9 " ]; then
  ok "strings.ludic (str ops, interpolation, slicing)"
else bad "strings: $(tail -1 /tmp/str.out)"; fi
# Scenes: one scene active at a time; only its layers' handlers run each phase
# (global handlers first, then the active scene's layers in declaration order).
# `become` runs the source scene's on-exit, switches, runs the target's on-enter.
# The active scene is snapshotted per phase, so the switch shows next phase (Play
# renders the frame it is entered). Trace: boot 1000, enter Title 1, Tick 101,
# Tick 102 -> become (exit 2, enter 3), Draw 900, Step 201, Draw 900, Step 202
# -> quit, Draw 900.
if ./selfhost/game-build.sh build/ludicc examples/scenes.ludic "/tmp/ludic_scn" >/tmp/scn.out 2>&1 \
   && [ "$(printf 'aaaaaaaaaa' | /tmp/ludic_scn | tr '\n' ' ')" = "1000 1 101 102 2 3 900 201 900 202 900 " ]; then
  ok "scenes.ludic (scene/layer/on enter/on exit/become)"
else bad "scenes: $(tail -1 /tmp/scn.out)"; fi
# Structural attach/detach + @OnAttach/@OnDetach: attach seeds a property on a
# live entity and fires @OnAttach (5+10=15), one Shield matches (1), detach fires
# @OnDetach reading the outgoing value (5+20=25) then clears it (0).
if ./selfhost/game-build.sh build/ludicc examples/detach.ludic "/tmp/ludic_det" >/tmp/det.out 2>&1 \
   && [ "$(/tmp/ludic_det </dev/null | tr '\n' ' ')" = "15 1 25 0 " ]; then
  ok "detach.ludic (attach/detach + @OnAttach/@OnDetach)"
else bad "detach: $(tail -1 /tmp/det.out)"; fi
# LC1 reason-carrying teardown: one @OnDespawn(M, reason: r) hook branches on the
# EndReason each site passes. An in-world despawn -> Despawned (drop loot 3+500),
# a survivor at quit -> Quit (skip loot 9+1000; no silent deaths).
if ./selfhost/game-build.sh build/ludicc examples/reason.ludic "/tmp/ludic_rsn" >/tmp/rsn.out 2>&1 \
   && [ "$(/tmp/ludic_rsn </dev/null | tr '\n' ' ')" = "503 1009 " ]; then
  ok "reason.ludic (@OnDespawn reason: Despawned vs Quit)"
else bad "reason: $(tail -1 /tmp/rsn.out)"; fi
# EV0 the event bus: `event E { payload }` + `@On(E)` listeners fired by `emit`.
# emit Hurt(3,5) -> Flash 5, Guard 8; Hurt(10,20) -> 20, 30; Cleared -> 999;
# Hurt(amount:42) with entity defaulting to 0 -> 42, 42. Listeners run in
# declaration order; the whole thing desugars to a direct @ev_<E> call.
if ./selfhost/game-build.sh build/ludicc examples/events.ludic "/tmp/ludic_evt" >/tmp/evt.out 2>&1 \
   && [ "$(/tmp/ludic_evt </dev/null | tr '\n' ' ')" = "5 8 20 30 999 42 42 " ]; then
  ok "events.ludic (event/emit/@On — the event bus core)"
else bad "events: $(tail -1 /tmp/evt.out)"; fi
# A pure-Ludic example that drives and asserts itself from its own `entry`: compile
# headless to IR, let clang assemble it (no C compiled — clang is only the IR
# assembler, the floor Rust/Swift stand on), run, and compare stdout.
netcase() {  # name  expected-output(space-joined)
  local n="$1" exp="$2"
  build/ludicc --headless "examples/$n.ludic" --emit-llvm -o "/tmp/$n.ll" >"/tmp/$n.out" 2>&1 \
    && ${LUDIC_CC:-clang} -O2 "/tmp/$n.ll" -o "/tmp/ludic_$n" >>"/tmp/$n.out" 2>&1 || { bad "$n: build ($(tail -1 /tmp/$n.out))"; return; }
  local got; got=$("/tmp/ludic_$n" </dev/null | tr '\n' ' ' | sed 's/ *$//')
  [ "$got" = "$exp" ] && ok "$n ($got)" || bad "$n: got [$got] want [$exp]"
}
# EV0b the event bus with two listeners on one event: Native prints each hit,
# Accum sums them. Fire 10 then 32 -> 10, 32, 42. (Pure Ludic; was a C mod.)
netcase mod_events "10 32 42"
# NETWORKING N0–N6 (NETWORKING-DESIGN.md) — every phase is a self-contained Ludic
# program, driven and asserted from its own `entry`. No C host and no C compiled.
# The transport is the compiler's built-in loopback (an `extern fn` overrides it
# with a real socket in production), so a networked game runs with zero foreign code.
# N0 transport seam: net_send/net_poll — the built-in loopback (no extern host)
netcase net_echo     "4 10 20 30 42"
# N1 world snapshot to a buffer: world_size/world_save/world_load (rollback substrate)
netcase net_snapshot "50 7 50"
# N2 @Sync: per-model serialize/apply, selective — Player syncs 12 bytes, max kept mutated
netcase net_sync     "12 3 4 50 999"
# N3 @Owned: owner/set_owner/is_owner — fresh entity unowned, then assigned/tested
netcase net_owner    "-1 7 0 1"
# N4 remote events (RPCs): @ToServer emit → wire → net_pump re-emits (5+3=8)
netcase net_rpc      "0 8"
# N5 roles + drivable sim: @Server gated by set_role; tick_fixed() drives the phases
netcase net_roles    "1 102"
# N6 blessed runtime end to end: RPC input → authority applies → replicate → reconcile
netcase net_demo     "5 999 5"
# EV1 @Public hook promotion: a @Public @OnSpawn/@OnDespawn also emits the public
# event model_<M>_spawn / model_<M>_despawn, which native @On listeners (and
# foreign mods over the ABI) subscribe to. Two spawns -> Spawned 100,101; two
# despawns -> Died 200,201 (entity + reason(0) + 200).
if ./selfhost/game-build.sh build/ludicc examples/promote.ludic "/tmp/ludic_prm" >/tmp/prm.out 2>&1 \
   && [ "$(/tmp/ludic_prm </dev/null | tr '\n' ' ')" = "100 101 200 201 " ]; then
  ok "promote.ludic (@Public -> model_<M>_spawn/despawn events)"
else bad "promote: $(tail -1 /tmp/prm.out)"; fi
# EV3 cancellable events: a `cancellable` event fires before an action; a listener
# `cancel`s it and the caller reads the verdict from `emit E(...)` as an
# expression. Armor vetoes hits over 10: emit(5)->0, emit(15)->1; applying only
# un-vetoed damage leaves hp at 92.
if ./selfhost/game-build.sh build/ludicc examples/cancel.ludic "/tmp/ludic_cnl" >/tmp/cnl.out 2>&1 \
   && [ "$(/tmp/ludic_cnl </dev/null | tr '\n' ' ')" = "0 1 92 " ]; then
  ok "cancel.ludic (cancellable event + cancel + emit-as-expression)"
else bad "cancel: $(tail -1 /tmp/cnl.out)"; fi
# EV2 the world table: an ECS program that declares events also generates the mod
# reflection ABI, now callable from Ludic via the world_* builtins (world_prop_id/
# field_id/get/set/has/count/kind/model_id/query_next/spawn/register_prop/attach_dyn)
# — the same functions a foreign mod binds by name. Each driver below reads and
# writes the world by NAME, never having compiled against a fixed layout.
netcase world_get   "50 1 7"    # EV2  read/write a field by name (has 1, hp 50->7)
netcase world_scan  "2 110"     # EV2b count/kind/model_id — scan + identify by model
netcase world_spawn "1 42 1"    # EV2b world_spawn — create an entity by model id
netcase world_mixed "99"        # EV2b real struct offsets (qty after a ptr, byte 8)
netcase world_query "2 110"     # EV2b world_query_next — iterate bearers of a property
# EV6 re-entrancy bound: Ping's listener emits Pong and Pong's emits Ping — an
# event cycle. The @ev_depth cap makes the nesting trap as an early return, so the
# program terminates deterministically (n=16 at the cap) instead of hanging.
if ./selfhost/game-build.sh build/ludicc examples/recurse.ludic "/tmp/ludic_rec" >/tmp/rec.out 2>&1 \
   && [ "$(/tmp/ludic_rec </dev/null | tr '\n' ' ')" = "16 " ]; then
  ok "recurse.ludic (EV6: re-entrant emit is depth-bounded, no runaway cycle)"
else bad "recurse: $(tail -1 /tmp/rec.out)"; fi
# EV5 despawn drops an entity from later event-driven work: an @On(Tick) listener
# counts live Units; ticking twice gives 2, then the Unit is despawned and a third
# tick finds none, so the count stays 2.
netcase scoped "2"
# EV7 schema opening: register a NEW component (Mana) the game never declared, get a
# prop id that works with the same get/set/has ABI, attach it, and keep per-entity
# storage isolated. has 0->1, fields 30/100, name resolves (1), other entity's write
# doesn't corrupt the first (still 30).
netcase world_dyn "0 1 30 100 1 30"
# EV1 for properties: @Public on @OnAttach/@OnDetach promotes to prop_<P>_attach /
# prop_<P>_detach, extending public events past models to properties. Attaching
# then detaching Shield on entity 0 -> Gained 300, Lost 400.
if ./selfhost/game-build.sh build/ludicc examples/prop_events.ludic "/tmp/ludic_pe" >/tmp/pe.out 2>&1 \
   && [ "$(/tmp/ludic_pe </dev/null | tr '\n' ' ')" = "300 400 " ]; then
  ok "prop_events.ludic (@Public -> prop_<P>_attach/detach events)"
else bad "prop events: $(tail -1 /tmp/pe.out)"; fi
# EV1 for scenes: a `public` scene promotes on-enter/on-exit to scene_<S>_enter /
# scene_<S>_exit. Boot enters Menu (10, listener 1); `become Game` leaves Menu (20,
# listener 2) and enters Game (30, listener 3).
if ./selfhost/game-build.sh build/ludicc examples/scene_events.ludic "/tmp/ludic_se" >/tmp/se.out 2>&1 \
   && [ "$(/tmp/ludic_se </dev/null | tr '\n' ' ')" = "10 1 20 2 30 3 " ]; then
  ok "scene_events.ludic (public scene -> scene_<S>_enter/exit events)"
else bad "scene events: $(tail -1 /tmp/se.out)"; fi
# EV1 for the program scope: @Public @OnStart/@OnQuit -> program_start/program_quit.
# Boot fires @OnStart(1) then program_start(100); shutdown fires @OnQuit(2) then
# program_quit(200) -> the top-level mod entry/exit points.
if ./selfhost/game-build.sh build/ludicc examples/program_events.ludic "/tmp/ludic_pge" >/tmp/pge.out 2>&1 \
   && [ "$(/tmp/ludic_pge </dev/null | tr '\n' ' ')" = "1 100 2 200 " ]; then
  ok "program_events.ludic (@Public @OnStart/@OnQuit -> program_start/quit)"
else bad "program events: $(tail -1 /tmp/pge.out)"; fi
# EV1 for layers (+ SCENES E2 layer toggle): a `public` layer + `enable/disable
# layer L` flips the layer (its handlers stop) and fires layer_<L>_show/hide.
# Frame 1 Draw(50) then disable->Hidden(2); frame 2 Draw gated off, enable->Shown(1);
# frame 3 Draw(50) then quit. Needs input frames, so feed keys.
if ./selfhost/game-build.sh build/ludicc examples/layer_events.ludic "/tmp/ludic_le" >/tmp/le.out 2>&1 \
   && [ "$(printf 'aaaa' | /tmp/ludic_le | tr '\n' ' ')" = "50 2 1 50 " ]; then
  ok "layer_events.ludic (layer toggle + public layer -> layer_<L>_show/hide)"
else bad "layer events: $(tail -1 /tmp/le.out)"; fi
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
printf 'entry { exit(42) }\n' > /tmp/cli_exit.ludic
./ludic /tmp/cli_exit.ludic >/tmp/cli.out 2>&1
if [ "$?" -eq 42 ]; then ok "ludic app.ludic  ->  compiles, runs, forwards exit code"
else bad "ludic run: expected exit 42, got $? ($(tail -1 /tmp/cli.out))"; fi

echo
printf "== %d passed, %d failed ==\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
