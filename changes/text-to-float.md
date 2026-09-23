bump: minor
type: feat
**`Text.to_float(s)`** - a leading decimal number read from a string as a `float` (`strtod`
underneath), the twin of `Text.to_int`. A game's data files carry fractions - an effect's
strength, a model's reach - and there was no way to read one back.
