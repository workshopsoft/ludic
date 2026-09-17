bump: patch
type: fix
`Crypto.random_bytes`, `Crypto.random_hex`, `Crypto.random_u32` and `Uuid.*` draw from the
system CSPRNG on Windows (`RtlGenRandom`, advapi32). They read `/dev/urandom`, which Windows
does not have, and every byte came back zero.
