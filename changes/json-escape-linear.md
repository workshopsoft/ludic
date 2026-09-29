bump: patch
type: fix
**`Json.parse` decodes an escaped string in one pass.** A string with escapes in it was joined a character
at a time, and every shorter copy was kept: a long escaped text took gigabytes (ui-preview's story model
reached 6.5 GB in three seconds). It is now decoded into one buffer sized from the text. ui-preview's
protocol-v1.md states how an `@import` path is resolved and which key a `file` override answers to.
