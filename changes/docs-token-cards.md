bump: patch
type: fix
**Token cards are back on the docs site.** Clicking a keyword, type, builtin or
namespace method in any code sample opens its summary card again. The card's
styling had been left behind in `docs.css` during the site redesign, so on the
landing page — which links only `base.css` and `site.css` — the card rendered
unstyled at the foot of the document instead of beside the token. It now lives
in `base.css` with the rest of the highlighter chrome, and is positioned
`fixed`, matching the viewport coordinates the script computes, so a card opened
on a scrolled reference page lands on its token rather than off it.
