---
id: ui
title: Ui
order: 43
---

The retained-mode menu API over a <code>ui</code> block. <a href="ui-build"><code>Ui.build</code></a> constructs every declared widget tree once (after fonts and skins are loaded); <a href="ui-open"><code>Ui.open</code></a> makes one menu active and <a href="ui-close"><code>Ui.close</code></a> deactivates it; the frame loop ticks navigation on its own, an activation fires the <code>UiClicked</code> event, and <a href="ui-clicked"><code>Ui.clicked</code></a> is the polled form; <a href="ui-set_text"><code>Ui.set_text</code></a> updates a label or button, and <a href="ui-render"><code>Ui.render</code></a> draws the active menu (call it from an <code>Overlay</code> handler so it paints over the world). Every <code>id: Name</code> in a <code>ui</code> block mints a <code>UI_Name</code> handle.
