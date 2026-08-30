#!/bin/sh
# Lint every commit summary in a git range against the Conventional Commits rule.
# Used by the commit-lint CI job; usable by hand too:
#
#   tools/git-hooks/lint-range.sh origin/main..HEAD
#
# With no argument it lints just the tip commit. Reports every commit, then exits
# non-zero if any failed.
set -e
RANGE="${1:-HEAD~1..HEAD}"

. "$(dirname "$0")/lib.sh"

# Collect subjects into a file so the loop runs in this shell (a pipe would put
# it in a subshell and lose the verdict). Merge commits are exempt by the rule
# and skipped here so a merge subject never trips the lint.
tmp=$(mktemp)
git log --no-merges --format='%s' "$RANGE" > "$tmp"

fail=0
while IFS= read -r subject; do
  [ -n "$subject" ] || continue
  if conventional_ok "$subject"; then
    echo "  ok    $subject"
  else
    echo "  FAIL  $subject"
    conventional_help "$subject"
    fail=1
  fi
done < "$tmp"
rm -f "$tmp"

[ "$fail" -eq 0 ]
