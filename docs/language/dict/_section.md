---
id: dict
title: Dict
order: 12
---

A hash map from string keys to <code>int</code> values — the everyday lookup a game needs, like resource counts or an id registry by name. A <code>Dict</code> is backed by an open-addressing hash table (FNV-1a, linear probing, tombstone deletes, growing at load factor 0.7), so <code>get</code>/<code>set</code>/<code>has</code> are O(1) on average rather than the linear scan a list would give. Create one with <code>Dict.new</code>, then <code>set</code> / <code>get</code> / <code>get_or</code> / <code>has</code> / <code>remove</code> / <code>size</code> / <code>clear</code> / <code>keys</code>. Values are <code>int</code> (which also holds an <code>entity</code> or any small id); for richer values use the <code>Value.*</code> tree. Arguments are positional. The runtime is spliced in only when a program mentions <code>Dict.*</code> (or <code>Set.*</code>).
