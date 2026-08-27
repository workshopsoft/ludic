#!/bin/bash
# compile.sh — compile a .ludic file with the self-hosted compiler and link it.
#   ./selfhost/compile.sh <selfhost-binary> <input.ludic> <output-binary>
set -eu
cd "$(dirname "$0")/.."
SH="$1"; IN="$2"; OUT="$3"
"$SH" "$IN" > "$OUT.ll"
clang "$OUT.ll" -o "$OUT"
