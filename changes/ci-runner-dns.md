bump: patch
type: docs
CONTRIBUTING documents what a self-hosted Forgejo runner needs for CI to work at
all: every workflow clones `${{ github.server_url }}`, which on a self-hosted
instance is an internal address, so job containers must be able to resolve it.
The runner's default is a fresh per-job network the Forgejo container is not on,
which fails the clone — intermittently, because Docker forwards unresolved names
to the host resolver, so CI can look healthy for a while before it stops.
