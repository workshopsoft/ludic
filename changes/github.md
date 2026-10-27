bump: patch
type: change
**Ludic lives on GitHub.** The repository is `github.com/workshopsoft/ludic`, the documentation and the
installer are at `https://workshopsoft.github.io/ludic/`, and releases are GitHub Releases.

- **`install.sh`** reads the release list from the GitHub API (`$LUDIC_GITHUB_API`).
- **`ludic upgrade` and `ludic doctor`** fetch the installer from the new address.
- **`ludic-dev publish`** creates the release through the `gh` CLI with `$GH_TOKEN`; in CI that is the
  workflow's own token.
