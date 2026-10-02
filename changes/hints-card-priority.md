bump: minor
type: feat
ludic.hints: a card's `priority` (0..9, default 0) orders the cards of one urgency on the rail.

The rail ranked by urgency and then by registry order, so a card that is true only for a while
(dusk coming, first light) could never take a place from a standing tip that happened to be
earlier in the registry. A card now carries a `priority`; within an urgency the higher one takes
a place first, and equal priorities keep the registry's order, so a registry that sets none ranks
as it did.
