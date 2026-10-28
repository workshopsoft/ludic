---
id: fs-mount
name: Fs.mount
category: fs
kind: namespace-method
tokens: Fs.mount
sig: Fs.mount(path: string) -> bool
tip: Mount a pack file so its entries are found first.
order: 13
ns: Fs
member: mount
---

Maps a <code>.lpak</code> or <code>.lmap</code> pack at run time. Its entries are searched before the packs listed in <code>packs.index</code>. Returns <code>true</code> when it was mounted; <code>false</code> when the file cannot be opened, is not a pack, or eight packs are already mounted.
