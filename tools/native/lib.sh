# tools/native/lib.sh - what every package's native/build.sh shares (phase 15). Sourced, not run.
#
# A native library is built here from a pinned source, never downloaded as a binary: the upstream
# tag is fetched, its SHA-256 checked, and it and the package's shim compiled with clang into
# lib/<target>/. The same script runs on the Mac (Terminal) and on the PC (Git Bash, with the LLVM
# installer's clang), so there is one recipe per library, not two.
set -eu

# macos-arm64, macos-x64, windows-x64 or linux-x64 - the names `native` lines use
native_target() {
  if [ -n "${LUDIC_NATIVE_TARGET:-}" ]; then echo "$LUDIC_NATIVE_TARGET"; return; fi
  case "$(uname -s)" in
    Darwin) if [ "$(uname -m)" = arm64 ]; then echo macos-arm64; else echo macos-x64; fi ;;
    MINGW*|MSYS*|CYGWIN*) echo windows-x64 ;;
    *) echo linux-x64 ;;
  esac
}

# the clang that builds: $LUDIC_CC, else clang on PATH, else the LLVM installer's on Windows
native_cc() {
  if [ -n "${LUDIC_CC:-}" ]; then echo "$LUDIC_CC"; return; fi
  if command -v clang >/dev/null 2>&1; then echo clang; return; fi
  if [ -x "/c/Program Files/LLVM/bin/clang.exe" ]; then echo "/c/Program Files/LLVM/bin/clang.exe"; return; fi
  echo "native: no clang (set LUDIC_CC)" >&2; exit 1
}
native_cxx() {
  local cc; cc="$(native_cc)"
  case "$cc" in *clang.exe) echo "${cc%clang.exe}clang++.exe" ;; *clang) echo "${cc}++" ;; *) echo "$cc" ;; esac
}

native_sha256() {
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1
  else sha256sum "$1" | cut -d' ' -f1; fi
}

# native_fetch <dir> <url> <sha256>: the archive at url, checked, unpacked into <dir> (its one
# top-level directory stripped). A checksum that does not match stops the build.
native_fetch() {
  local dir="$1" url="$2" want="$3"
  local tgz="$dir.tar.gz"
  mkdir -p "$(dirname "$dir")"
  if [ ! -f "$tgz" ]; then curl -fsSL "$url" -o "$tgz.part" && mv "$tgz.part" "$tgz"; fi
  local got; got="$(native_sha256 "$tgz")"
  if [ "$got" != "$want" ]; then
    echo "native: $url is $got, pinned $want" >&2; rm -f "$tgz"; exit 1
  fi
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir.part" && tar -xzf "$tgz" -C "$dir.part" --strip-components 1 && mv "$dir.part" "$dir"
  fi
}

# native_link <package dir> <name> <objects...>: lib<name>.dylib (install name @rpath, so the
# executable finds it beside itself, in Contents/Frameworks or in lib/<target> while developing)
# or <name>.dll with its import library <name>.lib, into <package>/lib/<target>/
native_link() {
  local pkg="$1" name="$2"; shift 2
  local t; t="$(native_target)"
  local out="$pkg/lib/$t"
  mkdir -p "$out"
  local cxx; cxx="$(native_cxx)"
  case "$t" in
    macos-*)
      "$cxx" -dynamiclib -O2 -Wl,-install_name,@rpath/lib$name.dylib -Wl,-dead_strip "$@" -o "$out/lib$name.dylib"
      echo "native: $out/lib$name.dylib" ;;
    windows-*)
      # -implib, not /implib: Git Bash rewrites an argument starting with "/" into a Windows path
      "$cxx" -shared -O2 "$@" -o "$out/$name.dll" -Wl,-implib:"$out/$name.lib"
      echo "native: $out/$name.dll + $name.lib" ;;
    *)
      "$cxx" -shared -O2 -fPIC -Wl,-soname,lib$name.so "$@" -o "$out/lib$name.so"
      echo "native: $out/lib$name.so" ;;
  esac
}

# the flags every object is compiled with: optimised, position independent, symbols hidden unless
# the shim exports them
native_cflags() {
  case "$(native_target)" in
    windows-*) echo "-O2" ;;
    *) echo "-O2 -fPIC -fvisibility=hidden" ;;
  esac
}
