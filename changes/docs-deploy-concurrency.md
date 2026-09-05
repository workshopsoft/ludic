bump: patch
type: ci
The docs deploy is serialised. Publishing is a force-push of an orphan `pages`
branch, so two runs racing could land out of order and leave the site holding the
older build — with both runs reporting success. A `pages-deploy` concurrency
group with `cancel-in-progress` means a newer push cancels an older in-flight
build instead of queueing behind it.
