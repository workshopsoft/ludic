#!/bin/bash
# build-tools.sh — build the Ludic editor toolchain.
#
#   ./tools/build-tools.sh              -> build/ludic-fmt, build/ludic-lsp
#   ./tools/build-tools.sh --test       build, then run tools/test-tools.sh
#   ./tools/build-tools.sh --install    also symlink both into ~/.local/bin
#
# Both binaries are written in Ludic (tools/ludic-tools/fmt.ludic, lsp.ludic) and
# compiled by the Ludic compiler itself — no C is compiled. clang only assembles
# the emitted LLVM IR, the same floor the compiler stands on. The vocabulary the
# grammar/lexer share still lives in tools/ludic-tools/ludic_syntax.h (data, read
# by check-vocabulary.py); the tools carry their own copy of it in Ludic.
set -e
cd "$(dirname "$0")/.."

CC="${LUDIC_CC:-clang}"
SRC=tools/ludic-tools
OUT=build

mkdir -p "$OUT"

# the Ludic compiler, assembled from the checked-in IR seed (C-free)
if [ ! -x "$OUT/ludicc" ] || [ selfhost/ludicc.seed.ll -nt "$OUT/ludicc" ]; then
  echo "cc: selfhost/ludicc.seed.ll -> $OUT/ludicc  (from the IR seed, no C compiler)"
  $CC selfhost/ludicc.seed.ll -o "$OUT/ludicc"
fi

build_ludic() {
  local name="$1" src="$2"
  if [ -x "$OUT/$name" ] && [ ! "$src" -nt "$OUT/$name" ] && [ ! "$OUT/ludicc" -nt "$OUT/$name" ]; then
    echo "$name: up to date"; return
  fi
  echo "ludicc: $src -> $OUT/$name  (Ludic -> LLVM IR -> binary, no C)"
  "$OUT/ludicc" "$src" --emit-llvm -o "$OUT/$name.ll" >/dev/null 2>&1 \
    && $CC -O2 "$OUT/$name.ll" -o "$OUT/$name" \
    && rm -f "$OUT/$name.ll" || { echo "build failed: $name"; exit 1; }
}

build_ludic ludic-fmt "$SRC/fmt.ludic"
build_ludic ludic-lsp "$SRC/lsp.ludic"

# VS Code needs the grammar inside its own extension directory, so it gets a
# copy. A copy that can drift is the whole failure mode this toolchain is built
# to avoid, so it is refreshed here rather than maintained by hand, and
# test-tools.sh asserts the two are identical.
SHARED=tools/editors/shared
VSC=tools/editors/vscode
if [ -d "$VSC" ]; then
  mkdir -p "$VSC/syntaxes"
  for f in ludic.tmLanguage.json ludic.markdown-injection.json; do
    cmp -s "$SHARED/$f" "$VSC/syntaxes/$f" || { cp "$SHARED/$f" "$VSC/syntaxes/$f"; echo "sync: $f -> $VSC/syntaxes/"; }
  done
  cmp -s "$SHARED/language-configuration.json" "$VSC/language-configuration.json" || {
    cp "$SHARED/language-configuration.json" "$VSC/language-configuration.json"
    echo "sync: language-configuration.json -> $VSC/"
  }
fi

if [ "$1" = "--install" ] || [ "$2" = "--install" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$PWD/$OUT/ludic-fmt" "$HOME/.local/bin/ludic-fmt"
  ln -sf "$PWD/$OUT/ludic-lsp" "$HOME/.local/bin/ludic-lsp"
  echo "linked into ~/.local/bin (make sure it is on your PATH)"
fi

if [ "$1" = "--test" ] || [ "$2" = "--test" ]; then
  exec ./tools/test-tools.sh
fi

echo "done. editors: see tools/editors/README.md"
