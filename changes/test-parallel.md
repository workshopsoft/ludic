bump: minor
type: feature
**`ludic test -j N` runs tests side by side.** Every file is compiled, linked and every test block
run as up to N jobs at once (default: the machine's CPU count), each test with a `TMPDIR` of its own,
and the report comes out in file order. `ludic test packages` takes about half the time.
