---
id: kw-public
name: public
category: structure
kind: keyword
tokens: public
sig: scene Name start public { … }
tip: Expose a declaration's lifecycle on the public event bus.
order: 11
---

<code>public</code> marks a <code>scene</code>, <code>layer</code>, or <code>event</code> as part of the game's public surface, so its lifecycle is emitted as named events other systems and mods can react to with <code>@On</code>. A <code>public</code> scene fires <code>scene_&lt;Name&gt;_enter</code> and <code>scene_&lt;Name&gt;_exit</code>; a <code>public</code> layer fires <code>layer_&lt;Name&gt;_show</code> / <code>_hide</code>. It is the declaration-level counterpart to the <code>@Public</code> annotation that promotes a model or handler's lifecycle hooks. Keep it off by default and add it only where the modding surface genuinely needs the hook.

```ludic
program Flow {
  @On(scene_Menu_enter) handler Greet { print(1) }

  scene Menu start public {
    on enter { print(10) }   # entering Menu prints 10, then fires scene_Menu_enter
    on exit  { print(20) }
  }
}
```
