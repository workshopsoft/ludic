bump: minor
type: feature
**`t()` in a template: a key and its holes for the translator.** `{t('pause.resume')}` and `{t('hud.day', day)}` make
the text the game's translator decodes at draw time: the key marked (byte 1; a key already marked, such as
a plural's byte 2, keeps its mark), then each hole's value after a byte 31. The text goes through the memo,
so a key and holes that read the same as last frame make nothing. Phase 26 (i18n keys).
