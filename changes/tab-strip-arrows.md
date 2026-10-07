bump: minor
type: feat
ludic.ui: arrows in a tab strip, as HTML's `role="tablist"` does them. Left and Right walk the
`role="tab"` siblings (wrapping), Down from a tab goes to the first focusable control of the panel
it controls (`aria-controls` names the panel's id; with none, the first control after the strip),
and Up from that control returns to the tab marked `aria-selected`. Elsewhere the arrows move the
focus as before.
