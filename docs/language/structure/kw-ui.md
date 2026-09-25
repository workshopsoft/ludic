---
id: kw-ui
name: ui
category: structure
kind: keyword
tokens: ui
sig: ui { panel { … } }
tip: Declare a retained widget tree as data; the engine lays it out and draws it.
order: 50
---

A <code>ui</code> block declares a <b>retained</b> widget tree as data — panels, labels and buttons — and hands layout, drawing and keyboard focus to the engine, so you describe the interface once instead of repainting it every frame. Widget types are `panel` (a container with optional skin/background/border), `col`/`row` (pure stacks), `label`, `button` (focusable), `image` and `spacer`, and their props are evaluated at build time, so `font: TitleScreenState.title_font` reads a value the program set first (a `ui` block names a state's one instance by the state's name). Each `id: Name` mints a `UI_Name` handle you drive from handlers: call `Ui.build()` then `Ui.open(UI_MainMenu)` at start, `Ui.tick(Input.key())` each update to move focus and activate, and `Ui.clicked(UI_Name)` to react. Draw it during `Render` with `Ui.render()` between `Screen.clear` and `Screen.show()`.

```ludic
program TitleScreen {
  state TitleScreenState {
    title_font: int = 0
  }

  ui MainMenu {
    panel id: Root w: 288 pad: 16 gap: 6 bg: 0x1a1a2c align: center {
      label  text: "CHRONO RIFT" font: TitleScreenState.title_font size: 26 fg: 0xffe060 align: center
      button id: NewGame text: "New Game" font: TitleScreenState.title_font size: 16 w: 236
      button id: Quit    text: "Quit"     font: TitleScreenState.title_font size: 16 w: 236
    }
  }

  handler Boot(title_screen_st: mut TitleScreenState) phase Start {
    title_screen_st.title_font = Font.load("/System/Library/Fonts/Supplemental/Arial.ttf")
    Ui.build()
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
