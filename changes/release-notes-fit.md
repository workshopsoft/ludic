bump: patch
type: fix
**`ludic-dev publish` fits the notes into a GitHub release.** GitHub refuses notes over 125 000
characters, and v0.23.0's section was twice that. Notes past 120 000 are cut before the first entry
that would cross it and end with a link to the whole section in `CHANGELOG.md` at the tag.
