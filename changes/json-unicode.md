bump: patch
type: fix
**`Json.parse` decodes `\uXXXX`.** An escaped code point is UTF-8 now - a surrogate pair joined into one, a
lone surrogate or bad hex as U+FFFD - where the backslash was dropped and the hex kept as text ("iu015f"),
and `\t`, `\r`, `\b` and `\f` are the characters they name. Python's `json.dump` writes non-ASCII this way.
