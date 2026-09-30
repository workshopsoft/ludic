#!/bin/sh
# native/build.sh - builds lib/<target>/ and gen/ for ludic.steamworks from the developer's own Steamworks SDK.
#
#   STEAMWORKS_SDK=~/sdk/steamworks sh native/build.sh
#
# The SDK is Valve's, under an agreement that keeps it out of an open toolchain, so nothing of it is in this
# repository: the generator (tools/steam_gen.ludic) reads the SDK's steam_api.json and writes gen/, the shim and
# the generated wrappers are compiled against the SDK's headers, and the SDK's runtime library is copied beside
# the result. lib/, gen/ and build/ are git-ignored. Runs in Git Bash on Windows, like every native/build.sh
# (tools/native/lib.sh).
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
. "$PKG/native/lib.sh"

SDK="${STEAMWORKS_SDK:-}"
T="$(native_target)"

# already built from this SDK's description and this source: nothing to do (a hook may run this before every build)
GEN="$PKG/gen/steam_raw.ludic"
if [ -f "$GEN" ] && [ -z "${STEAMWORKS_REBUILD:-}" ] && ls "$PKG/lib/$T"/*ludicsteam* >/dev/null 2>&1; then
  fresh=1
  for src in "$PKG/native/shim/steamshim.cpp" "$PKG/tools/steam_gen.ludic" "$PKG/native/build.sh" "${SDK:+$SDK/public/steam/steam_api.json}"; do
    if [ -n "$src" ] && [ "$src" -nt "$GEN" ]; then fresh=0; fi
  done
  if [ "$fresh" = 1 ]; then echo "steamworks: lib/$T and gen/ are up to date"; exit 0; fi
fi

if [ -z "$SDK" ]; then
  echo "steamworks: set STEAMWORKS_SDK to the Steamworks SDK's folder (the one holding public/ and redistributable_bin/)" >&2
  exit 1
fi
if [ ! -f "$SDK/public/steam/steam_api.json" ]; then
  echo "steamworks: $SDK/public/steam/steam_api.json is not there: STEAMWORKS_SDK must name the SDK's root" >&2
  exit 1
fi

OUT="$PKG/lib/$T"
OBJ="$PKG/build/native"
mkdir -p "$OBJ" "$OUT" "$PKG/gen"

# 1. the bindings, from this SDK's own description of itself
LUDIC="${LUDIC:-ludic}"
"$LUDIC" build "$PKG/tools/steam_gen.ludic" -o "$PKG/build/steam_gen" >/dev/null
"$PKG/build/steam_gen" --sdk "$SDK" --out "$PKG/gen"

# 2. the SDK's runtime library for this target, beside what links against it
case "$T" in
  macos-*)
    RT="$SDK/redistributable_bin/osx/libsteam_api.dylib"
    cp "$RT" "$OUT/libsteam_api.dylib"
    # found through @rpath (the build's rpath to lib/<target>, a bundle's Contents/Frameworks)
    install_name_tool -id @rpath/libsteam_api.dylib "$OUT/libsteam_api.dylib" 2>/dev/null
    codesign -f -s - "$OUT/libsteam_api.dylib" >/dev/null 2>&1 || true
    LINK_SDK="$OUT/libsteam_api.dylib" ;;
  windows-*)
    cp "$SDK/redistributable_bin/win64/steam_api64.dll" "$OUT/steam_api64.dll"
    cp "$SDK/redistributable_bin/win64/steam_api64.lib" "$OUT/steam_api64.lib"
    LINK_SDK="$OUT/steam_api64.lib" ;;
  *)
    cp "$SDK/redistributable_bin/linux64/libsteam_api.so" "$OUT/libsteam_api.so"
    LINK_SDK="$OUT/libsteam_api.so" ;;
esac

# 3. the shim and the generated wrappers, compiled against the SDK's headers
CXX="$(native_cxx)"
for src in "$PKG/native/shim/steamshim.cpp" "$PKG/gen/lsg_wrap.cpp"; do
  "$CXX" -std=c++14 $(native_cflags) -I"$SDK/public" -c "$src" -o "$OBJ/$(basename "$src" .cpp).o"
done
native_link "$PKG" ludicsteam "$OBJ/steamshim.o" "$OBJ/lsg_wrap.o" "$LINK_SDK"
