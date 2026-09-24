bump: minor
type: feature
**Default parameters, views and templates.** A parameter can have a default (`pad: float = 8.0`).
A call leaves out what it does not change, and may pass its first arguments by position and the
rest by name.

A `view` declaration is the one bridge between a program and its UI. It names the fields a
template may read, the functions it may ask and the `on` events it may send, and it writes
`view_<name>() -> UiView`.

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

Screens are drawn through a registered renderer. `Value` gains a float kind.

Also:
- A program's function named like one of the runtime's is refused; it had been silently taking the
  runtime's own calls.
- An index is evaluated before the slice's elements are read. A `xs[f()]` whose `f` grew `xs`
  read stale memory.
- A runtime error names the file its expression is in, not the program's.
