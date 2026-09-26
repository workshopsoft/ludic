#!/bin/sh
# builds lib/<target>/ for ludic.physics: Jolt Physics at a pinned tag, and the shim over it.
# Cross-platform determinism is on (the Mac and the PC must agree in co-op), and floating point
# contraction off, which it needs. Objects go to build/native; about a minute on eight cores.
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
. "$PKG/../../tools/native/lib.sh"
JOLT_TAG=v5.6.0
JOLT_SHA=6e069ee0172478cc78182047aac87e5310ba14a67a53348ae14cc37801fd3f8e
SRC="$PKG/build/src/jolt-$JOLT_TAG"
native_fetch "$SRC" "https://github.com/jrouwe/JoltPhysics/archive/refs/tags/$JOLT_TAG.tar.gz" "$JOLT_SHA"

OBJ="$PKG/build/native/$(native_target)"
mkdir -p "$OBJ"
CXX="$(native_cxx)"
DEFS="-DNDEBUG -DJPH_CROSS_PLATFORM_DETERMINISTIC -DJPH_OBJECT_LAYER_BITS=16"
FLAGS="$(native_cflags) -std=c++17 -ffp-contract=off -fno-exceptions -fno-rtti $DEFS -I$SRC"
case "$(native_target)" in windows-*) FLAGS="$FLAGS -D_CRT_SECURE_NO_WARNINGS" ;; esac
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"

# one object per Jolt source, named by its path so two files called the same do not collide
( cd "$SRC" && find Jolt -name '*.cpp' ) | while read -r f; do
  o="$OBJ/$(echo "$f" | tr '/' '_' | sed 's/\.cpp$/.o/')"
  [ "$o" -nt "$SRC/$f" ] || echo "$f $o"
done | xargs -P "$JOBS" -n 2 sh -c '"$0" '"$FLAGS"' -c "'"$SRC"'/$1" -o "$2"' "$CXX"
"$CXX" $FLAGS -I"$PKG/native/shim" -c "$PKG/native/shim/jph_shim.cpp" -o "$OBJ/jph_shim.o"

native_link "$PKG" ludicjolt "$OBJ"/*.o
