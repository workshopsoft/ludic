#!/bin/sh
# check/run.sh - the smoke check of the real SDK (needs STEAMWORKS_SDK; builds lib/ and gen/ when they are missing)
set -eu
PKG="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -f "$PKG/gen/steam_raw.ludic" ] || ! ls "$PKG"/lib/*/ >/dev/null 2>&1; then
  sh "$PKG/native/build.sh"
fi
LUDIC="${LUDIC:-ludic}"
cd "$PKG/check"
"$LUDIC" run smoke.ludic
