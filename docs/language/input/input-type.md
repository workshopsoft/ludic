---
id: input-type
name: Input.type
category: input
kind: namespace-method
tokens: Input.type
sig: Input.type(text: string) -> bool
tip: Queue typed text for the next Input.text.
order: 62
ns: Input
member: type
---

Types text as if the player had, for tests, tutorials and the devlink <code>text</code> verb. It is queued, at most 256 bytes, and returned by the next <a href="input-text"><code>Input.text()</code></a> when the window typed nothing that frame. Returns <code>false</code>, queueing nothing, when it would not fit.
