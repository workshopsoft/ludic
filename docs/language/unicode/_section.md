---
id: unicode
title: Unicode
order: 6
---

Correct-by-default text over UTF-8. Player names, translated menus, and chat arrive as UTF-8 bytes, and counting *bytes* gets non-ASCII text wrong — the wrong length, and truncation that slices a character in half into mojibake. The <a href="ns-Unicode"><code>Unicode</code></a> namespace works in <strong>code points</strong> and (approximately) <strong>grapheme clusters</strong> instead, so measuring, indexing, truncating, and case-mapping behave for every language.

This is the correctness layer, not a replacement: the byte-oriented <a href="ns-Text"><code>Text</code></a> operations stay for speed on ASCII and for raw byte work. Reach for <code>Unicode.*</code> whenever the text came from a human — a name, a message, a localized string.

Three notions of "length" matter, and the API keeps them distinct: <a href="unicode-byte_len"><code>byte_len</code></a> (storage), <a href="unicode-len"><code>len</code></a> (code points — Unicode scalar values), and <a href="unicode-grapheme_len"><code>grapheme_len</code></a> (user-perceived characters, where a base letter plus its combining accent, or a ZWJ emoji sequence, count as one).

**Coverage (v1):** decoding and <a href="unicode-is_valid_utf8"><code>validation</code></a> cover the full UTF-8 range. Case mapping covers ASCII and the Latin-1 letters — correct for Western-European text; wider scripts (Latin-Extended, Greek, Cyrillic), locale rules (Turkish <code>i</code>, German <code>ß</code>), and NFC normalization are follow-ups. <a href="unicode-grapheme_len"><code>grapheme_len</code></a> approximates UAX#29 for the cases real player text hits — combining marks, variation selectors, ZWJ sequences, and flag pairs.
