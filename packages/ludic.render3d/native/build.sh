#!/bin/sh
# builds lib/macos-arm64/libMoltenVK.dylib: Vulkan over Metal, which render3d draws with on a Mac.
# MoltenVK at a pinned tag, its SHA-256 checked; its dependencies (SPIRV-Cross, SPIRV-Tools,
# Vulkan-Headers, ...) come at the commits its own ExternalRevisions pins. Needs Xcode (not only the
# command line tools); about fifteen minutes. Windows needs nothing: its drivers install the loader.
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
. "$PKG/../../tools/native/lib.sh"
case "$(native_target)" in macos-*) ;; *) echo "ludic.render3d: nothing to build for $(native_target)";  exit 0 ;; esac
MVK_TAG=v1.4.2
MVK_SHA=6864db532f1dbbdb621a8d0ec13f24edae318fd9269dd3dd0cdff791334bb1cb
SRC="$PKG/build/src/moltenvk-$MVK_TAG"
native_fetch "$SRC" "https://github.com/KhronosGroup/MoltenVK/archive/refs/tags/$MVK_TAG.tar.gz" "$MVK_SHA"
XCODE="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
( cd "$SRC" && DEVELOPER_DIR="$XCODE" ./fetchDependencies --macos && DEVELOPER_DIR="$XCODE" make macos )
OUT="$PKG/lib/$(native_target)"
mkdir -p "$OUT"
# the release is Apple silicon only: the arm64 slice, found by the executable's rpath
lipo "$SRC/Package/Release/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib" -thin arm64 -output "$OUT/libMoltenVK.dylib"
install_name_tool -id @rpath/libMoltenVK.dylib "$OUT/libMoltenVK.dylib" 2>/dev/null
# the id change breaks the signature, and Apple silicon loads no unsigned code: signed ad hoc here,
# with the Developer ID by ludic bundle / vpk for a release
codesign -f -s - "$OUT/libMoltenVK.dylib"
cp "$SRC/LICENSE" "$PKG/native/LICENSE-MoltenVK"
echo "$OUT/libMoltenVK.dylib"
