#!/bin/sh
# builds lib/<target>/ for ludic.nativeecho: no upstream library, only the shim
# (tools/native/lib.sh; a package that wraps a library adds native_fetch first - see ludic.physics)
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
. "$PKG/../../tools/native/lib.sh"
OBJ="$PKG/build/native"
mkdir -p "$OBJ"
"$(native_cc)" $(native_cflags) -c "$PKG/native/shim/nativeecho.c" -o "$OBJ/nativeecho.o"
native_link "$PKG" nativeecho "$OBJ/nativeecho.o"
