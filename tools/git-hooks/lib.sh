# lib.sh — shared Conventional Commits validation, sourced by the commit-msg
# hook and by the CI commit-lint job so the rule lives in exactly one place.
# POSIX sh; no bashisms.

# The allowed commit types (Conventional Commits + the ones this repo uses).
CONVENTIONAL_TYPES='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'

# conventional_ok <header-line> -> 0 if it conforms, non-zero otherwise.
# Accepts `type(scope): summary`, an optional `!` for a breaking change, and the
# housekeeping headers git itself writes (merge/revert) or autosquash markers.
conventional_ok() {
  header="$1"
  [ -n "$header" ] || return 1
  case "$header" in
    "Merge "*|"Revert "*|"fixup! "*|"squash! "*|"amend! "*) return 0 ;;
  esac
  printf '%s\n' "$header" \
    | grep -qE "^($CONVENTIONAL_TYPES)(\([a-z0-9][a-z0-9,._/ -]*\))?(!)?: .+"
}

# conventional_help <header-line> — print a short, actionable explanation.
conventional_help() {
  echo "  commit summary is not a Conventional Commit:"
  echo "      ${1:-<empty>}"
  echo
  echo "  expected:  type(scope): summary        (scope is optional)"
  echo "  types:     feat fix docs style refactor perf test build ci chore revert"
  echo "  examples:  feat(stdlib): add Regex.* namespace"
  echo "             fix(emit): stop fixed compares widening the int literal"
  echo "             ci: cache the clang toolchain between runs"
  echo "             refactor(stdlib)!: drop the deprecated System.env alias"
  echo
  echo "  see https://www.conventionalcommits.org"
}
