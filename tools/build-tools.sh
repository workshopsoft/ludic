#!/bin/bash
# build-tools.sh — build the Ludic editor toolchain.
#
#   ./tools/build-tools.sh              -> build/ludic-fmt, build/ludic-lsp
#   ./tools/build-tools.sh --test       build, then run tools/test-tools.sh
#   ./tools/build-tools.sh --install    also symlink both into ~/.local/bin
#
# Both binaries are plain C with no dependencies, same as the compiler. They
# share the lexer and vocabulary in tools/ludic-tools/ludic_syntax.h, so a
# keyword added there reaches every editor at once.
set -e
cd "$(dirname "$0")/.."

CC="${LUDIC_CC:-clang}"
CFLAGS="-O2 -Wall -Wno-unused-function"
SRC=tools/ludic-tools
OUT=build

mkdir -p "$OUT"

build_one() {
  local name="$1" main="$2"
  local newest
  # rebuild when any header or the entry point is newer than the binary
  if [ -x "$OUT/$name" ]; then
    newest=$(find "$SRC" -name '*.h' -o -name "$(basename "$main")" | while read -r f; do
      [ "$f" -nt "$OUT/$name" ] && echo new
    done) || true
    if [ -z "$newest" ]; then echo "$name: up to date"; return; fi
  fi
  echo "cc: $main -> $OUT/$name"
  $CC $CFLAGS "$main" -o "$OUT/$name"
}

build_one ludic-fmt "$SRC/ludic_fmt_main.c"
build_one ludic-lsp "$SRC/ludic_lsp.c"

# The language server shells out to the compiler for real diagnostics, so having
# it around is most of the value.
if [ ! -x "$OUT/ludicc" ]; then
  echo "note: $OUT/ludicc not built yet — run ./build.sh for compiler diagnostics"
fi

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
