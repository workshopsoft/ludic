---
id: kw-friend
name: friend
category: structure
kind: keyword
tokens: friend
sig: friend module name [of a, b]
tip: A module that sees other modules' private names - the lab, the tests.
order: 53
---

<code>friend module lab</code> declares a module that may name every private name of every module; <code>friend module lab of bank, sky</code> limits it to those. It is for test and staging code that must reach inside a system without the system exporting its internals.

```ludic
# doc-check: skip — a module spans files
friend module lab of bank, sky
```
