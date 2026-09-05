bump: patch
type: ci
The docs deploy triggers on a change to `install.sh`. The site publishes the
installer, but the workflow's path filter did not mention it — so a release that
only fixed `install.sh` left the old script live at the URL the landing page
tells people to pipe into `sh`.
