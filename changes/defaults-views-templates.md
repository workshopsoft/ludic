bump: minor
type: feature
**Default parameters, components, views and templates.** A parameter can have a default (`pad: float = 8.0`).
A call leaves out what it does not change, and may pass its first arguments by position and the
rest by name.

A `view` declaration is the one bridge between a program and its UI. It names the fields a
template may read, the functions it may ask and the `on` events it may send, and it writes
`view_<name>() -> UiView`.

A `component Name { prop, state, fields, functions, on events }` declaration beside `Name.xml` and
`Name.lss` is a UI component. Its template and styles are compiled in (with `@import` inlined), each
mounted instance keeps its own props and state, styles are scoped to it, and a parent's `class`,
`style` and `id` land on its root.

`ludic.ui` is now a template runtime. Screens and components are XML files loaded at run time,
with:
- `{expression}` bindings;
- `<if>`, `<else>` and `<each>`;
- props, `<slot/>` and per-instance `<state>`;
- `on-press` actions that send events, `set` state or `emit` to the component's user;
- component libraries (`export="true"`, `<import src as>`);
- HTML's elements (`div`, `p`, `h1`-`h6`, `ul`/`li`, `img`, `hr`, ...), with a default stylesheet;
- HTML's attributes: `id`, `class`, `style`, `hidden`, `disabled` and `onclick`, with any other
  attribute kept for selectors;
- the CSS box model (padding and margin in 1-4 values, borders, `px` and `%`) and flex layout
  (`flex-grow`, `justify-content`, `align-items`/`align-self`, `flex-wrap`, min and max sizes)
  under CSS's property names;
- stylesheets, in a `<style>` or an `.lss` file (a Ludic StyleSheet) that others import and that
  can `@import` more;
- CSS's selectors: `#id`, compound classes, `[attr=value]`, descendant and `>` combinators,
  `:hover`, `:disabled`, `:first-child`, `:last-child`, `:nth-child`, `:not` and more, weighed by
  specificity.

- more CSS: custom properties and `var()`, `position` with insets and `z-index`, `em`/`rem`/`vw`/`vh`,
  `@media`, wrapping text and ellipsis, `overflow`, `+`/`~`, `:nth-child(an+b)`, `:checked`, `:active`;
- more React: keyed lists, `<let>`, `<provide>` context, `<fragment>`, named slots, `on-mount` and
  `on-unmount`;
- native elements a program draws itself (`ui_native`, `ui_fire`), and form controls;
- errors with file and line, hot reload (`ui_reload`), and an inspector-style dump.

The runtime is a UI framework, not only a template engine:
- it takes input itself: focus and keyboard navigation, the pointer, scroll boxes, `autofocus`;
- it has built-in controls (button, checkbox, radio, range, select, text, key), styled as CSS
  parts;
- `ludic.ui/render3d.ludic` is a render3d backend, with textures, atlases, nine-slices, clipping
  and scale;
- more CSS: `rgba()`/`#rrggbbaa`, `border-radius`, `outline`, `box-shadow`, `background-image`,
  `border-image`, group `opacity`, `@keyframes` / `animation` / `transition`;
- HTML mixed content, and boolean attributes;
- hooks for the program's language, sounds and clock.

render3d gains `tex_width` / `tex_height`, and the XML reader keeps text runs among elements in
order (`mixed`).

A `view` field set to a literal or a named function's result needs no type.

Screens are drawn through a registered renderer. `Value` gains a float kind.

Also:
- A program's function named like one of the runtime's is refused; it had been silently taking the
  runtime's own calls.
- An index is evaluated before the slice's elements are read. A `xs[f()]` whose `f` grew `xs`
  read stale memory.
- A runtime error names the file its expression is in, not the program's.
