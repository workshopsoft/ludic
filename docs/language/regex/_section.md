---
id: regex
title: Regex
order: 26
---

Regular expressions with PCRE/PECL-compatible syntax over a **linear-time** Thompson NFA (a Pike VM), so a bad pattern from a modder can never trigger catastrophic backtracking — matching is <code>O(n·m)</code>, never exponential. Compile a pattern once and reuse it; an invalid pattern is an <a href="regex-compile"><code>error value</code></a>, never a crash. Supported: literals, <code>.</code>, classes <code>[...]</code> with ranges/negation and <code>\d \w \s</code> (and their negations), anchors <code>^ $</code>, alternation <code>|</code>, capturing and <code>(?:…)</code> groups, and the quantifiers <code>* + ?</code> and <code>{n,m}</code> in greedy or lazy form. Backreferences and look-around are out of scope for a linear engine.
