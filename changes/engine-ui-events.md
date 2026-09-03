bump: minor
type: feat
engine-driven retained UI — a program with a `ui` block has its navigation ticked by the frame loop automatically (from the frame key) and an activation now emits a `UiClicked { id }` event, so scenes react with `@On(UiClicked)` instead of polling `Ui.clicked`. New `Ui.*` namespace (`Ui.open/tick/clicked/set_text/render/build`).
