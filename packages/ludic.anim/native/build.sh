#!/bin/sh
# builds lib/<target>/ for ludic.anim: ozz-animation at a pinned tag - its base, its runtime jobs and
# the offline builders that make a skeleton and a clip at load - and the shim over them. No CMake,
# no glTF importer: the game reads the glTF and hands the shim its numbers. Objects go to build/native
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
. "$PKG/../../tools/native/lib.sh"
OZZ_TAG=0.17.0
OZZ_SHA=22b4401c77a2be68acb0a8aa2e857f94dbaccfed3ab25e304a1ddea4c546e86b
SRC="$PKG/build/src/ozz-$OZZ_TAG"
native_fetch "$SRC" "https://github.com/guillaumeblanc/ozz-animation/archive/refs/tags/$OZZ_TAG.tar.gz" "$OZZ_SHA"

OBJ="$PKG/build/native/$(native_target)"
mkdir -p "$OBJ"
CXX="$(native_cxx)"
FLAGS="$(native_cflags) -std=c++17 -DNDEBUG -fno-exceptions -fno-rtti -I$SRC/include -I$SRC/src"
case "$(native_target)" in windows-*) FLAGS="$FLAGS -D_CRT_SECURE_NO_WARNINGS" ;; esac
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"

# the base and the runtime whole, and of the offline library only what builds a skeleton and a clip
( cd "$SRC" && find src/base src/animation/runtime -name '*.cc'
  for f in raw_skeleton skeleton_builder raw_animation raw_animation_utils animation_builder; do echo "src/animation/offline/$f.cc"; done
) | while read -r f; do
  o="$OBJ/$(echo "$f" | tr '/' '_' | sed 's/\.cc$/.o/')"
  [ "$o" -nt "$SRC/$f" ] || echo "$f $o"
done | xargs -P "$JOBS" -n 2 sh -c '"$0" '"$FLAGS"' -c "'"$SRC"'/$1" -o "$2"' "$CXX"
"$CXX" $FLAGS -I"$PKG/native/shim" -c "$PKG/native/shim/ozz_shim.cpp" -o "$OBJ/ozz_shim.o"

native_link "$PKG" ludicozz "$OBJ"/*.o
