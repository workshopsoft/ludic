bump: minor
type: feat
**City buildings carry a roof kind.** `ludic.city`'s `Buildings` rows have a free-string `roof` field (a word the game's
kits know, such as `gable` or `hip`; `""`, the default, means flat). It loads as written and reaches
`CityInstances.roof`, so a game can map each word to a kit.
