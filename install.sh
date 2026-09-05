#!/bin/sh
# install.sh — install the Ludic toolchain.
#
#   curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh
#
# That URL is the documentation site, which publishes this file alongside the
# pages it is quoted on (see cmd_docs_gen). Everything host-shaped here is a
# variable with an environment override, so moving the project — a new domain,
# a new forge, a new name for the language — is an edit to the block below and
# to the prose that quotes it (CONTRIBUTING.md has the checklist).
#
# It puts a complete toolchain — the compiler, the `ludic` CLI, the formatter,
# the language server, the engine runtime and the bundled ludic.* packages —
# under ~/.ludic, and puts ~/.ludic/bin on your PATH. Nothing else on the system
# is touched, and uninstalling is `rm -rf ~/.ludic`.
#
# Where a prebuilt toolchain exists for the platform it is downloaded and
# checksum-verified. Where it does not, the source is fetched and bootstrapped
# from the compiler's own checked-in LLVM IR seed, which needs only clang and
# takes a few seconds — the same path a contributor uses.
#
# Options (also usable through `ludic upgrade`):
#   --version X.Y.Z     install that release instead of the latest
#   --dir PATH          install root (default: $HOME/.ludic)
#   --no-modify-path    do not touch any shell profile
#   --from-source       skip the prebuilt artifacts and bootstrap from source
#   --help
#
# POSIX sh on purpose: this is the first thing a new user runs, and it has to
# work on a stock macOS /bin/sh and on a minimal Linux image alike.

set -eu

REPO_API="${LUDIC_FORGEJO_API:-https://git.workshopsoft.io/api/v1/repos/workshopsoft/ludic}"
REPO_URL="${LUDIC_REPO_URL:-https://git.workshopsoft.io/workshopsoft/ludic}"
INSTALL_URL="${LUDIC_INSTALL_URL:-https://workshopsoft.pages.workshopsoft.io/ludic/install.sh}"
INSTALL_DIR="${LUDIC_INSTALL_DIR:-${HOME}/.ludic}"
VERSION=""
MODIFY_PATH=1
FROM_SOURCE=0

# ---- output -----------------------------------------------------------------

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  B=$(printf '\033[1m'); DIM=$(printf '\033[2m'); R=$(printf '\033[0m')
  GREEN=$(printf '\033[32m'); RED=$(printf '\033[31m')
else
  B=''; DIM=''; R=''; GREEN=''; RED=''
fi

say()  { printf '%s\n' "$*"; }
step() { printf '%s==>%s %s\n' "$B" "$R" "$*"; }
warn() { printf '%swarning:%s %s\n' "$RED" "$R" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$RED" "$R" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<EOF
install.sh — install the Ludic toolchain.

  curl -fsSL ${INSTALL_URL} | sh

  --version X.Y.Z     install that release instead of the latest
  --dir PATH          install root (default: $HOME/.ludic)
  --no-modify-path    do not touch any shell profile
  --from-source       skip the prebuilt artifacts and bootstrap from source
  --help              this message
EOF
  exit 0
}

# ---- arguments --------------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="${2:-}"; [ -n "$VERSION" ] || die "--version needs a value"; shift 2 ;;
    --version=*) VERSION="${1#*=}"; shift ;;
    --dir) INSTALL_DIR="${2:-}"; [ -n "$INSTALL_DIR" ] || die "--dir needs a value"; shift 2 ;;
    --dir=*) INSTALL_DIR="${1#*=}"; shift ;;
    --no-modify-path) MODIFY_PATH=0; shift ;;
    --from-source) FROM_SOURCE=1; shift ;;
    -h|--help) usage ;;
    *) die "unknown option: $1  (try --help)" ;;
  esac
done

VERSION="${VERSION#v}"

# ---- platform ---------------------------------------------------------------

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  aarch64) ARCH=arm64 ;;
  amd64)   ARCH=x86_64 ;;
esac
case "$OS" in
  darwin|linux) ;;
  *) die "unsupported platform: $OS ($ARCH). Ludic builds on macOS and Linux." ;;
esac

# clang assembles and links the IR the compiler emits, so it is required to
# build any Ludic program — not only to install from source.
CC_HINT=''
if ! have clang && ! have cc; then
  if [ "$OS" = darwin ]; then
    CC_HINT='install the Command Line Tools:  xcode-select --install'
  else
    CC_HINT='install clang, e.g.  apt-get install clang   /   dnf install clang'
  fi
fi

have curl || die "this installer needs curl"

# ---- downloading ------------------------------------------------------------

fetch() { curl -fsSL "$1" -o "$2"; }

# The newest published release, e.g. "0.4.0".
#
# /releases/latest excludes pre-releases, and every 0.x release is marked one —
# so on a project that has not reached 1.0 that endpoint 404s and the installer
# would refuse to install anything at all. Fall back to the full list, which is
# newest-first and includes pre-releases.
latest_version() {
  _v=$(curl -fsSL "${REPO_API}/releases/latest" 2>/dev/null | first_tag)
  [ -n "$_v" ] || _v=$(curl -fsSL "${REPO_API}/releases?limit=1" 2>/dev/null | first_tag)
  printf '%s\n' "$_v"
}

first_tag() {
  sed -n 's/.*"tag_name" *: *"v\{0,1\}\([^"]*\)".*/\1/p' | head -1
}

sha256_of() {
  if have sha256sum; then sha256sum "$1" | cut -d' ' -f1
  elif have shasum;   then shasum -a 256 "$1" | cut -d' ' -f1
  else return 1
  fi
}

# download the toolchain tarball for this platform into $TMP, verify it against
# the published checksum, and echo its path. Silent failure (returns 1) means
# "no prebuilt for this platform" — the caller falls back to source.
download_prebuilt() {
  _name="ludic-${VERSION}-${OS}-${ARCH}.tar.gz"
  _url="${REPO_URL}/releases/download/v${VERSION}/${_name}"
  _out="${TMP}/${_name}"
  fetch "$_url" "$_out" 2>/dev/null || return 1
  if fetch "${_url}.sha256" "${_out}.sha256" 2>/dev/null; then
    _want=$(cut -d' ' -f1 < "${_out}.sha256")
    _got=$(sha256_of "$_out" || true)
    if [ -n "$_got" ] && [ "$_want" != "$_got" ]; then
      die "checksum mismatch for ${_name} (expected ${_want}, got ${_got})"
    fi
    [ -n "$_got" ] || warn "no sha256 tool found; the download was not verified"
  else
    warn "no published checksum for ${_name}; the download was not verified"
  fi
  printf '%s\n' "$_out"
}

# ---- installing -------------------------------------------------------------

# Replace the install root with the staged tree. The swap is done at the end so
# an interrupted download never leaves a half-installed toolchain behind, and a
# working install is only removed once the new one is ready to take its place.
# Is this directory a usable install root? A toolchain is not just binaries: a
# game links against the engine runtime and resolves the bundled packages from
# here, so an artifact missing them installs something that cannot build
# anything. Older releases predate this layout, which is exactly the case that
# must degrade to a source build rather than to a broken ~/.ludic.
valid_root() {
  [ -x "${1}/bin/ludic" ] && [ -x "${1}/bin/ludicc" ] \
    && [ -d "${1}/runtime/native" ] && [ -f "${1}/VERSION" ]
}

install_staged() {
  _staged="$1"
  valid_root "$_staged" || die "the staged toolchain is incomplete"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "${INSTALL_DIR}.old"
    mv "$INSTALL_DIR" "${INSTALL_DIR}.old"
  fi
  mv "$_staged" "$INSTALL_DIR"
  rm -rf "${INSTALL_DIR}.old"
}

# Build the toolchain from the source of a tag: clang assembles the compiler's
# own IR seed, that compiler builds the CLI, and the CLI builds the rest. This
# is the only step Ludic cannot do for itself, and it is also the whole story of
# how the language bootstraps.
install_from_source() {
  have git || die "installing from source needs git"
  have clang || have cc || die "installing from source needs clang. ${CC_HINT}"
  step "building from source (no prebuilt toolchain for ${OS}-${ARCH})"
  _src="${TMP}/src"
  git clone --quiet --depth 1 --branch "v${VERSION}" "${REPO_URL}.git" "$_src" 2>/dev/null \
    || git clone --quiet --depth 1 "${REPO_URL}.git" "$_src" \
    || die "could not clone ${REPO_URL}"
  # A release older than the CLI cannot produce one, and the build would fail
  # deep inside clang with nothing pointing at the cause.
  [ -f "${_src}/tools/ludic-cli/main.ludic" ] || die "release v${VERSION} predates the ludic CLI; install a newer one with --version X.Y.Z"
  CC=clang; have clang || CC=cc
  ( cd "$_src" \
    && mkdir -p bin \
    && "$CC" selfhost/ludicc.seed.ll -o bin/ludicc 2>/dev/null \
    && bin/ludicc tools/ludic-cli/main.ludic -o bin/ludic \
    && bin/ludic dev build >/dev/null ) || die "the source build failed"

  _stage="${TMP}/stage"
  mkdir -p "${_stage}/bin"
  cp "${_src}"/bin/ludic "${_src}"/bin/ludicc "${_src}"/bin/ludic-fmt "${_src}"/bin/ludic-lsp "${_stage}/bin/"
  cp -R "${_src}/runtime" "${_stage}/runtime"
  cp -R "${_src}/packages" "${_stage}/packages"
  cp "${_src}/VERSION" "${_src}/LICENSE" "${_src}/README.md" "${_stage}/"
  install_staged "$_stage"
}

# ---- PATH -------------------------------------------------------------------

# The shell profiles worth touching: the login shell's, plus ~/.profile as the
# catch-all. Appending a guarded line is the least surprising thing an installer
# can do to someone's dotfiles, and it is easy to find and delete.
profiles() {
  case "${SHELL:-}" in
    */zsh)  printf '%s\n' "${ZDOTDIR:-$HOME}/.zshrc" ;;
    */bash) printf '%s\n' "$HOME/.bashrc" ;;
    */fish) printf '%s\n' "$HOME/.config/fish/config.fish" ;;
  esac
  [ -f "$HOME/.profile" ] && printf '%s\n' "$HOME/.profile"
  return 0
}

add_to_path() {
  _bin="${INSTALL_DIR}/bin"
  case ":${PATH}:" in *":${_bin}:"*) return 0 ;; esac
  [ "$MODIFY_PATH" -eq 1 ] || return 0
  _added=''
  for _p in $(profiles); do
    [ -e "$_p" ] || continue
    if grep -q 'ludic/bin\|LUDIC_INSTALL' "$_p" 2>/dev/null; then _added="$_p"; continue; fi
    case "$_p" in
      */config.fish) printf '\n# Ludic\nset -gx PATH %s $PATH\n' "$_bin" >> "$_p" ;;
      *)             printf '\n# Ludic\nexport PATH="%s:$PATH"\n' "$_bin" >> "$_p" ;;
    esac
    _added="$_p"
  done
  PATH_NOTE="$_added"
}

# ---- go ---------------------------------------------------------------------

TMP=$(mktemp -d "${TMPDIR:-/tmp}/ludic-install.XXXXXX")
trap 'rm -rf "$TMP"' EXIT INT TERM

if [ -z "$VERSION" ]; then
  step "looking up the latest release"
  VERSION=$(latest_version || true)
  [ -n "$VERSION" ] || die "could not determine the latest version (set one with --version X.Y.Z)"
fi
say "  ludic ${B}${VERSION}${R}  ${DIM}${OS}-${ARCH}  ->  ${INSTALL_DIR}${R}"

if [ "$FROM_SOURCE" -eq 1 ]; then
  install_from_source
else
  step "downloading the toolchain"
  if TARBALL=$(download_prebuilt); then
    STAGE="${TMP}/stage"
    mkdir -p "$STAGE"
    tar -xzf "$TARBALL" -C "$STAGE"
    # A current artifact unpacks to one top-level directory that is the install
    # root; an older one unpacks its contents directly. Try both, and if neither
    # is a usable root the release predates this layout — build from source
    # instead of installing something that cannot compile a game.
    ROOTDIR=""
    if valid_root "$STAGE"; then
      ROOTDIR="$STAGE"
    else
      for _d in "$STAGE"/*; do
        if [ -d "$_d" ] && valid_root "$_d"; then ROOTDIR="$_d"; break; fi
      done
    fi
    if [ -n "$ROOTDIR" ]; then
      install_staged "$ROOTDIR"
    else
      warn "the ${VERSION} artifact for ${OS}-${ARCH} is not a complete toolchain; building from source"
      install_from_source
    fi
  else
    install_from_source
  fi
fi

PATH_NOTE=''
add_to_path

# ---- report -----------------------------------------------------------------

INSTALLED=$("${INSTALL_DIR}/bin/ludic" version 2>/dev/null || echo "ludic ${VERSION}")
say ""
say "${GREEN}installed${R} ${INSTALLED}  ->  ${INSTALL_DIR}"

if [ -n "$CC_HINT" ]; then
  say ""
  warn "no clang found. Ludic emits LLVM IR and needs clang to assemble and link it."
  say "  ${CC_HINT}"
fi
if [ "$OS" != darwin ]; then
  say ""
  say "  ${DIM}note: windowing is macOS-only today. On ${OS}, programs build and run"
  say "  headless (ludic build --headless); a window will not open yet.${R}"
fi

say ""
if [ -n "$PATH_NOTE" ]; then
  say "  ${DIM}added ${INSTALL_DIR}/bin to your PATH in ${PATH_NOTE} — open a new shell, or:${R}"
  say "  export PATH=\"${INSTALL_DIR}/bin:\$PATH\""
  say ""
else
  case ":${PATH}:" in
    *":${INSTALL_DIR}/bin:"*) ;;
    *)
      say "  ${DIM}add this to your shell profile:${R}"
      say "  export PATH=\"${INSTALL_DIR}/bin:\$PATH\""
      say ""
      ;;
  esac
fi

say "next:"
say "  ${B}ludic new mygame${R}      create a project"
say "  ${B}cd mygame && ludic run${R}  build it and play"
say "  ${B}ludic help${R}            everything else"
