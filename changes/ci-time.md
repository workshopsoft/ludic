bump: patch
type: change
**CI spends its hour where it counts.** A push that changes only prose (`docs/`, `changes/`, Markdown)
runs the doc checks, now a job of their own (`docs-checks`: the fences, coverage of the
implementation and the site), and skips the regression and editor suites. The release workflow no
longer runs the suites a second time: it publishes once `ci` has passed on the tagged commit, or on
its parent when the tag's commit is `ludic-dev release`'s own (`VERSION`, `CHANGELOG.md`, `changes/`).
