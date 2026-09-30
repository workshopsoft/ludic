bump: minor
type: feat
**Starter templates and `ludic release`.** `ludic new <name> [--template <t>]` copies a starter and
`ludic templates [--json]` lists them: `blank` (the default, unchanged), `third-person` and
`first-person` (ludic.character over ludic.lab's plate), `2d-platformer` (ludic.platformer) and
`top-down` (a tile map), each checked with `ludic build --check`. The manifest gains `release` lines
(`release id`, `title`, `authors`, `channel <os> "<name>"`, `feed`, `keep`, `notes`, `entitlements`,
`sign`, `notary_profile`, `upload s3 "<bucket>" "<endpoint>"`, `dir`, `exe`, `icon`), and
`ludic release [--os osx|win|linux] [--dry-run] [--json] [--key-id ID --secret KEY]` turns them and the
bundle into Velopack's `vpk download s3`, `vpk pack` and `vpk upload s3`, stopping at the first
failure. `--dry-run` prints the exact commands with the credentials redacted, `--dry-run --json` the
plan as JSON. Credentials come from `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, never the
manifest, and a project's own `script "release"` still takes the command.
