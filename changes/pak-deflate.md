bump: minor
type: feat
`ludic pack` compresses an entry when that saves a tenth of it: maps' tables, a world's job files, models' geometry and a texture's
BC7 blocks shrink, while PNG, JPEG and audio, which are compressed already, are stored as they are. The pack format goes to version 2,
whose 24-byte entries add the file's own length and its codec. A version-1 pack still reads. A compressed entry is inflated as it is
opened, by the inflater the runtime already has (`runtime/native/inflate.ludic`), now compiled into every program that opens a file.
The encoder (`tools/ludic-cli/deflate.ludic`) comes within half a percent of zlib's level 6, and the 116 MB file of a game's road
job compresses to 30 MB and inflates in about a quarter of a second. `--verify` inflates every compressed entry and checks its hash,
`--store` writes every entry as it is, and `Fs.size` gives a compressed file's own length. A file imported under two spellings of its
path is now loaded once.
