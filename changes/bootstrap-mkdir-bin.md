bump: patch
type: fix
The documented bootstrap works on a fresh clone. `bin/` is gitignored and not
checked in, so `clang selfhost/ludicc.seed.ll -o bin/ludicc` — the first command
in the README, in COMPILING, in CONTRIBUTING and on the site — failed with
`ld: open() failed, errno=2 for 'bin/ludicc'`. Every copy now begins with
`mkdir -p bin`, which is what CI had been doing all along.
