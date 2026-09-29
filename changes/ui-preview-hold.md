bump: minor
type: feature
**ui-preview `hold`: a pseudo-class held on without input.** `hold "<id or key>" "hover"` (also `active`,
`focus`, `focus-visible`, `checked`, `disabled`) shows a story's element as if it were hovered or focused
from the next frame, on top of the real input; `tree`, `box` and `rules` answer as if it were real. `""`
lets go of one element's holds, `hold "" ""` of all, and `reset` clears them. ludic.ui keeps the holds
(`ui_hold`, `ui_hold_clear`, held.ludic); a game holds none, and the matcher's check of an empty table is all it costs.
