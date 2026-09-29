---
id: annot-alloc_ok
name: @alloc_ok
category: annotations
kind: annotation
tokens: @alloc_ok
sig: @alloc_ok("why") function f()  /  @alloc_ok("why") statement
tip: Allocates in a frame on purpose; the reason is required.
order: 80
---

<code>@alloc_ok("a memo miss, bounded by MM_CAP")</code> on a function or a single statement marks an allocation reachable from a frame as deliberate: the fence lets it through and <code>ludic deps</code> does not count it. The reason is required and greppable.
