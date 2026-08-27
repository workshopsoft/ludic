#!/bin/bash
# build-cli.sh — build the self-hosted Ludic front-end binaries.
#
# Both `ludicc` and `ludic` are the SAME native binary, compiled from the Ludic
# compiler's own IR seed (selfhost/ludicc.seed.ll) with clang alone — no C
# compiler. The binary is multi-call: it looks at argv[0], so invoked as
# `ludicc` it compiles, and invoked as `ludic` it compiles and runs.
#
#   ./build-cli.sh
#   ./ludicc examples/snake.ludic -o build/snake     # compile
#   ./ludic  examples/snake.ludic                     # compile + play
#
# The binaries locate the runtime (runtime/native/cocoa.ll) via $LUDIC_HOME,
# defaulting to the directory they sit in — so keep them at the repo root, or
# set LUDIC_HOME and put them on your PATH.
set -eu
cd "$(dirname "$0")"
CC="${LUDIC_CC:-clang}"
mkdir -p build

echo "cc: selfhost/ludicc.seed.ll -> ludicc/ludic  (from the IR seed, no C compiler)"
$CC selfhost/ludicc.seed.ll -o build/ludicc
cp build/ludicc ludicc
cp build/ludicc ludic
chmod +x ludicc ludic
echo "done. built ./ludicc and ./ludic"
