#!/bin/sh
# builds lib/<target>/ for ludic.nav: Recast & Detour at a pinned tag, and the shim over them.
# Recast builds the mesh, Detour answers it; DetourTileCache and DetourCrowd come with phases 17.8
# and 18. Polygon refs are 64-bit (DT_POLYREF64): an 8 km map in 64 m tiles is 16384 tiles, which
# 32-bit refs would leave 256 polygons each. Objects go to build/native; a few seconds on eight cores.
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
. "$PKG/../../tools/native/lib.sh"
RC_TAG=v1.6.0
RC_SHA=d48ca0121962fa0639502c0f56c4e3ae72f98e55d88727225444f500775c0074
SRC="$PKG/build/src/recast-$RC_TAG"
native_fetch "$SRC" "https://github.com/recastnavigation/recastnavigation/archive/refs/tags/$RC_TAG.tar.gz" "$RC_SHA"

OBJ="$PKG/build/native/$(native_target)"
mkdir -p "$OBJ"
CXX="$(native_cxx)"
INC="-I$SRC/Recast/Include -I$SRC/Detour/Include"
FLAGS="$(native_cflags) -std=c++17 -ffp-contract=off -fno-exceptions -fno-rtti -DNDEBUG -DDT_POLYREF64 $INC"
case "$(native_target)" in windows-*) FLAGS="$FLAGS -D_CRT_SECURE_NO_WARNINGS" ;; esac
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"

( cd "$SRC" && ls Recast/Source/*.cpp Detour/Source/*.cpp ) | while read -r f; do
  o="$OBJ/$(basename "$f" .cpp).o"
  [ "$o" -nt "$SRC/$f" ] || echo "$f $o"
done | xargs -P "$JOBS" -n 2 sh -c '"$0" '"$FLAGS"' -c "'"$SRC"'/$1" -o "$2"' "$CXX"
"$CXX" $FLAGS -I"$PKG/native/shim" -c "$PKG/native/shim/nav_shim.cpp" -o "$OBJ/nav_shim.o"

native_link "$PKG" ludicnav "$OBJ"/*.o
