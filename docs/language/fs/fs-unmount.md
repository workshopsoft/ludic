---
id: fs-unmount
name: Fs.unmount
category: fs
kind: namespace-method
tokens: Fs.unmount
sig: Fs.unmount(path: string) -> bool
tip: Give back a pack mounted from exactly this path.
order: 14
ns: Fs
member: unmount
---

Takes out of the search the pack that <a href="fs-mount"><code>Fs.mount</code></a> mapped from exactly <code>path</code>, gives its mapping back, and moves the later packs up a slot. Returns <code>true</code> when it was mounted. Close any file still open over one of its entries first.
