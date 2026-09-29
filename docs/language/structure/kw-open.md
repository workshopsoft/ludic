---
id: kw-open
name: open
category: structure
kind: keyword
tokens: open
sig: open registry Name of Record
tip: A registry other modules may add entries to with def.
order: 68
---

An <code>open registry</code> is one whose entries may come from other modules' <code>def</code>s, merged in a deterministic order; a closed one takes entries only from its own module. A package declares its table open so the game can fill it.
