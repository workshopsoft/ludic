---
id: type-key
name: Key
category: types
kind: type
tokens: Key
sig: k"module.purpose"  /  kn"module.purpose"
tip: A text key: it names a text and is not one - tr(key) makes the text.
order: 4
---

A `Key` names a text the player reads; its English lives in the source language's `.po`, like every other language's text. It is written `k"module.purpose"`, or `kn"..."` for a text with plural forms, against its quote. A `Key` is not a `string` and a `string` is not a `Key`: text is made with `tr(key)`, `trf(key, ...)` or, for a plural, `trn(kn"...", n, ...)`, and a key in a template literal's hole is an error. Keys compare with `==`, and with a `lang` line in `package.ludic` the compiler checks every one against the `.po`.

```ludic
# doc-check: skip — tr / trf / trn are ludic.i18n's
let title = tr(k"pause.resume")
let day = trf(k"hud.day", txt_num(n))
if key == k"pause.resume" { Screen.status(title) }
```
