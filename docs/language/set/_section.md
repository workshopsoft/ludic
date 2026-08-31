---
id: set
title: Set
order: 13
---

A set of string members — membership tests for tags, unlocked achievements, or visited tiles. A <code>Set</code> shares the same open-addressing hash table as <code>Dict</code>, so <code>add</code> / <code>has</code> / <code>remove</code> are O(1) on average and duplicates are ignored. Create one with <code>Set.new</code>, then <code>add</code> / <code>has</code> / <code>remove</code> / <code>size</code> / <code>clear</code> / <code>members</code>. Arguments are positional. The runtime is spliced in only when a program mentions <code>Set.*</code> (or <code>Dict.*</code>).
