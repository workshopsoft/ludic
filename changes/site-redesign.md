bump: minor
type: docs
The generated site is redesigned around reading rather than launching: a warm
paper ground with a serif display face, one ink-blue accent, and rules instead
of floating cards. Colour is reserved for code. Dark mode is the same design
with the ground inverted, driven entirely by tokens under one
`prefers-color-scheme` block, and the landing page's scroll-reveal animations,
gradient headline, glowing badge and emoji feature icons are gone.

- Stylesheets are linked files (`base.css` + `site.css`/`docs.css`) instead of
  being inlined into all 900+ pages, which cuts the published site from 16 MB to
  5 MB and means a design change no longer requires regenerating to be seen.
- Fonts are the platform's own; the site makes no webfont request.
- `api.css` was dead — the generator never referenced it — and is removed along
  with `item.css`, which `docs.css` replaces.
- A page no longer flashes its own title on every plain visit; only a deep link
  highlights its target, and under `prefers-reduced-motion` the highlight no
  longer stays on the element permanently.
- The copy leads with what is verifiable — ahead-of-time compiled, an ECS in the
  syntax, deterministic fixed-point, no C in a build — and the "get started"
  steps now begin with the clang-plus-seed bootstrap, without which `bin/x` does
  not exist on a clean checkout.
