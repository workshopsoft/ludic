---
id: assets-enqueue_dir
name: Assets.enqueue_dir
category: assets
kind: namespace-method
tokens: Assets.enqueue_dir
sig: Assets.enqueue_dir(path: dir)
tip: Enqueue every file of a directory, named by its file name.
order: 10
ns: Assets
member: enqueue_dir
---

Each file is enqueued under its name without the extension (<code>assets/audio/hit.wav</code> → <code>hit</code>); the queue sorts it by extension as usual, so a sound directory becomes the sound bank in one line.

```ludic
# doc-check: skip — illustrative
Assets.enqueue_dir(path: "assets/audio")
…
Audio.play(name: "hit")
```
