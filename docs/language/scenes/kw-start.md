---
id: kw-start
name: start
category: scenes
kind: keyword
tokens: start
sig: scene Name start { … }
tip: Marks the one scene the game begins in.
order: 50
---

`start` marks the scene the game begins in. Written right after the scene's name (`scene Title start { … }`), it tells the compiler which scene becomes active at boot: its `on enter` hook fires once, immediately after the `Start` phase, and its layers begin dispatching on the first frame. Mark <b>exactly one</b> scene `start`; if no scene is marked, the first one declared is used. Every other scene is reached later with `become`.

```ludic
program StartSceneExample {
  scene MainMenu start {
    on enter { Screen.status("main menu") }
    layer Menu {
      handler ChooseOption phase Update {
        if Input.key() == 'p' { become Overworld }
      }
      handler DrawMenu phase Render {
        Screen.clear(Color.MidnightBlue)
        Screen.draw_text(x: 40, y: 90, text: "PRESS P TO PLAY", color: Color.White, scale: 1)
        Screen.show()
      }
    }
  }

  scene Overworld {
    layer World {
      handler DrawWorld phase Render {
        Screen.clear(Color.MidnightBlue)
        Screen.fill_rectangle(x: 100, y: 100, width: 16, height: 16, color: Color.Gold)
        Screen.show()
      }
    }
  }
}
```
