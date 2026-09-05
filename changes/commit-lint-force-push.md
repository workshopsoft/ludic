bump: patch
type: ci
The commit-lint workflow survives a force-push. It linted
`${{ github.event.before }}..${{ github.sha }}` without checking that `before`
still resolves, so rewriting or garbage-collecting that commit failed the job
with `fatal: Invalid revision range` on a push whose messages were all valid. It
now falls back to linting the tip commit when `before` is gone.
