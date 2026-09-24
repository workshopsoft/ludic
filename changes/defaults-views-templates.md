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
- `popover` (a top layer that keeps the pointer and keys, with light dismissal), `title` tooltips,
  and `<progress>` / `<meter>`;
- importing `ludic.ui/render3d.ludic` installs the backend, and atlases take rows;
- hooks for the program's language, sounds and clock.

What a game's screens found missing, now in `ludic.ui`:
- `<input type="number" min max step>`: typed digits, Enter or leaving it commits them clamped, the
  arrows step it;
- `<input type="key">` listens for any key (Tab and the arrows included) once Enter or a click starts
  it; Esc stops it, Backspace clears it, `shown` names the value, and `ui_capturing()` tells the host;
- `note="..."` under any control's label (`.ui-note`); a range's `decimals`, `format="percent"` and
  `unit`; a track laid out as a row, with the range's fill as tall as it;
- popovers anchored beside an element (`anchor="id"`, or a bare `anchor` for the element before it,
  `placement`), flipped to the other side and kept on the screen;
- `flex-shrink` (a scroll box in a column takes the room its siblings leave), `flex: grow shrink`,
  `order`, and text in a row wrapping in the room its siblings leave;
- `calc()` over px, %, em, rem, vw, vh and `var()`; `width: 0` and `height: 0` mean 0;
- `text-shadow`; tooltips of several lines; `ui_opacity()` for a native's draw;
- `border-image` drawn as painted with no background colour, tinted by one, and not at all under
  `transparent`; a picture file drawn untinted (an atlas cell still takes `color`);
- the render3d backend loads a picture again when its file changes (`ui_image_reload`), draws a path
  with a drive letter as a path, and slices a nine-slice by its texture's own width and height;
- a component root that is itself a component takes every user's class, style and id, and the
  sheets that style it are weighed together by specificity;
- a component's event may be called `set`; a `string` prop given a number reads it as text; two
  components of one name are an error naming both files;
- the scrollbar is `.ui-scrollbar` and `.ui-thumb`: a press on the thumb holds it where it was taken,
  a press on the track jumps the thumb's middle there, and neither presses what is under the bar;
- a popover's own controls take its presses whatever lies under it, a press outside only closes it,
  and while one is up the scroll boxes outside it do not take the pointer;
- the first gamepad moves the focus (d-pad, left stick), steps ranges and selects, and presses (A)
  and goes back (B); a held direction, on the pad or the arrow keys, repeats after 0.42 s and then
  every 0.11 s on the ui clock (`UiInput.held_*`, `pad_a`, `pad_b` for a host);
- pointer events: `on-pointerdown` / `pointermove` / `pointerup` / `drag` / `wheel` with `event.x`,
  `y`, `dx`, `dy`, `button` and `wheel`, and `ui_native_input(tag, fn)` for a native; a press captures
  the pointer until release; the pointer hits the topmost element in painting order, and
  `pointer-events: none` lets it through;
- `on-down` and `on-up` on a button (the pointer, Enter or A), with `:active` true while it is held
  there rather than whenever the pointer is down over it;
- an anchored popover's `align="start|center|end"`, and `within="id"` (by default the nearest
  scroll box around it) for the bounds it is flipped against and kept inside;
- `text-fit: shrink MIN` shrinks a line to its box, then cuts it with an ellipsis; `line-height`;
  an `em` reads the font size the element ends with (a `font-size` later in the rule, or in a later
  rule), not the one it had so far;
- `min()`, `max()` and `clamp()`, in `calc()` or on their own; `top` / `right` / `bottom` / `left`
  as a percentage or a `calc()` of one, of the containing block;
- a nine-slice's corners are clamped to half the box in each direction on its own and cut on whole
  pixels (`ui_nine_cuts`), so a small key cap has no seam;
- `scroll-top="{px}"` holds a scroll box at an offset, with `on-scroll` when the player moves it;
  `ui_scroll_set(id, px)` moves one once;
- a transition lands exactly on its end value (it had stopped a rounding error short of it, at every
  frame rate).

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

Two declarations with one name (a package's private global and a program's, say) are reported as
such before type checking. They used to surface as a page of type errors about the wrong type.
