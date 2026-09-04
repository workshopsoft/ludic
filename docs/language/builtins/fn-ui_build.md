---
id: fn-ui_build
name: ui_build
category: builtins
kind: builtin
tokens: ui_build
sig: ui_build()
tip: Build the declared UI tree so it can be opened and rendered.
order: 50
---

Constructs the retained-UI tree you declared in a <code>ui</code> block, laying out its panels, labels, and buttons and loading any skins or images they reference. Call it once during a <code>Start</code>-phase handler, after loading any fonts the UI needs, and before you open a screen with <code>ui_open</code> or draw it with <code>ui_render</code>. Because the UI is declared as data and built in one step, the game code only has to build it, open it, and read clicks. It takes no arguments.

```ludic
program TitleMenu {
  var title_font: int = 0

  ui MainMenu {
    panel id: Root w: 240 pad: 16 gap: 6 bg: 0x1a1a2c align: center {
      label text: "CHRONORIFT" font: title_font size: 24 fg: 0xffe060 align: center
      button id: NewGame text: "New Game" font: title_font size: 16 w: 200
      button id: Quit    text: "Quit"     font: title_font size: 16 w: 200
    }
  }

  handler Boot phase Start {
    title_font = Font.load("/System/Library/Fonts/Supplemental/Arial.ttf")
    ui_build()
    Ui.open(UI_MainMenu)
  }

  handler Navigate phase Update {
    Ui.tick(Input.key())
    if Ui.clicked(UI_Quit) { quit() }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Ui.render()
    Screen.show()
  }
}
```
