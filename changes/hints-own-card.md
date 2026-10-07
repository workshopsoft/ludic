bump: minor
type: feature
**`ludic.hints`: who opened the card.** `HintsState.hn_own` is set when the player's key opens a card
(`hints_key`) and cleared whenever the card closes, is muted or goes; `hints_own` reads it and
`hints_keys_act` says what the arrows and Enter mean this frame - the card's walk and mute only for a
card the player opened, nothing (they pass through to the game) for one shown on its own.
