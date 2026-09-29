---
id: kw-as
name: as
category: structure
kind: keyword
tokens: as
sig: registry Name of Record as PREFIX
tip: The prefix of a registry's generated constants.
order: 65
---

<code>as P</code> after a registry's record makes the compiler write a constant for each entry, <code>P_KEY</code> in upper case, holding the entry's index - so code reads <code>IT_ROPE</code> rather than looking the key up.
