---
id: sprite-strip
name: Sprite.strip
category: sprite
kind: namespace-method
tokens: Sprite.strip
sig: Sprite.strip(sheet, col, row, count, rows) -> int
tip: A run of animation frames as consecutive sprite ids.
order: 9
ns: Sprite
member: strip
---

Registers <code>count</code> frames starting at cell (<code>col</code>, <code>row</code>), each <code>rows</code> cells tall, as consecutive ids and returns the first. With a <code>SpriteAnim</code> on the entity the engine adds the current frame to <code>Sprite.id</code>, so the strip's first id is all a spawn needs.

```ludic
# doc-check: skip — illustrative
let hero_run = Sprite.strip(sheet: sheet, col: 8, row: 2, count: 8, rows: 2)
spawn Hero { Sprite { id: hero_run, atlas: 1 }, SpriteAnim { fps: 8, frames: 4 } }
```
