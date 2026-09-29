bump: minor
type: feature
**English left is an error (phase 26.9).** Under a `lang` line, a template's own words, a text
attribute's, a quoted choice that reads as words and a `@Text` row still holding English now refuse
the build, where they were warnings; `ludic deps` still counts them as `english_left`. Hole counts and
undescribed splits stay warnings. ludic.ui's own words - the key field's "Right click", "Middle
click", "Left click" and "press a key..." - are keys (`ui_tk(ui_st, k"ui.right_click", plain)`,
`ui.*` in the program's `.po`), with their plain English for a program that binds no translator.
