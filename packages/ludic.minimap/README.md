# ludic.minimap

What a map knows without drawing anything: which cells of a grid have been walked, the marks the
player put on it, and where its window looks. The game paints the picture - the ground, the fog,
the icons, the legend - from the package's queries. Uses [`ludic.base`](../ludic.base/README.md)
and nothing else.

```ludic
import "ludic.minimap"
```

## The explored fog

A square grid of `cells` per side, `cell_m` metres each, centred on `MinimapWorld.origin`.
`minimap_reveal(x, z, r)` marks every cell any part of which lies within `r`; `minimap_version()`
goes up whenever what has been seen changes, so a baked fog texture is rebuilt only then.
**Explored** is a share of LAND, over a core square of the grid (`minimap_config_core`), so open
water is not unexplored and a bigger grid does not change what a chapter's "walk 30%" asks for.

## The marks

A mark (`MinimapPin { x, z, icon, colour, day, label }`) is a note at a place: it does not route
anyone and it does not move. There is a cap; `minimap_pin_add` answers -1 past it and the game
says so. One mark may be **open** (the legend edits it) and one **followed** (the game puts it on
its compass); a new mark takes the symbol last chosen. Rubbing one out moves the later ones up,
and the open and followed indices with them.

## The view

A square window of `size` pixels showing `span` metres across at zoom 1, centred on a world point
and kept inside `MinimapWorld`'s bounds. World to window (`minimap_px`, `minimap_py`) and back
(`minimap_wx`, `minimap_wz`, from a point measured from the window's corner), zoom in steps or
about a point (what is under the pointer stays under it), a drag that pans, a press that picks the
mark under it or drops a new one, "the camp" and "you", and a focus that goes there and closes in
but never pulls a closer view back out.

## The port

```ludic
export port MinimapWorld {       # every member has a default
  origin_x, origin_z             # the grid's centre
  land(x, z) -> bool             # what "explored" counts
  you_x, you_z, camp_x, camp_z   # the two places a view recentres on
  day() -> int                   # a mark remembers the day it was made
  lo_x, lo_z, hi_x, hi_z         # the view's centre stays inside these
}
```

## API

| | |
| --- | --- |
| `minimap_config(cells, cell_m)`, `minimap_config_core(from, n)`, `minimap_land_changed()` | the grid, the square explored is measured over, and a new ground under it |
| `minimap_reveal(x, z, r)`, `minimap_reveal_cell(c)` | walking |
| `minimap_cell(x, z)`, `minimap_cells()`, `minimap_cell_m()`, `minimap_cell_x(i)`, `minimap_cell_z(j)`, `minimap_grid_x0()`, `minimap_grid_z0()`, `minimap_grid_half()` | the grid's geometry |
| `minimap_seen(c)`, `minimap_seen_at(x, z)`, `minimap_seen_count()`, `minimap_version()`, `minimap_explored_pct()` | what has been seen |
| `minimap_seen_text()`, `minimap_seen_from_text(s)` | the grid as one string of 0 / 1 (an older save's shape) |
| `minimap_config_pins(max, symbols, colours)`, `minimap_pins_clear()` | the marks' cap and ranges |
| `minimap_pin_add(x, z, icon, label) -> int`, `minimap_pin_put(x, z, icon, colour, day, label)`, `minimap_pin_remove(i)` | a mark made today, one as saved, and rubbing one out |
| `minimap_pin_count()`, `minimap_pin_max()`, `minimap_pin_full()`, `minimap_pin(i) -> MinimapPin` | the marks |
| `minimap_pin_set_label/icon/colour(i, v)`, `minimap_pin_last_icon()` | editing one |
| `minimap_pin_open()`, `minimap_pin_select(i)`, `minimap_pin_followed()`, `minimap_pin_follow(i)`, `minimap_pin_follow_toggle()` | the open one and the followed one |
| `minimap_pins_near(x, z, n, within) -> []int` | the nearest marks, not the followed one (for a compass), in a list the state keeps and refills: read it, do not keep it |
| `minimap_config_view(span, zoom_min, zoom_max, focus)`, `minimap_window(x0, y0, size)` | the view's range, and where the window is this frame |
| `minimap_px(x)`, `minimap_py(z)`, `minimap_wx(rx)`, `minimap_wz(ry)`, `minimap_span()`, `minimap_scale()`, `minimap_scale_metres()` | projection, and a scale bar's round distance |
| `minimap_zoom()`, `minimap_zoom_set(z)`, `minimap_zoom_step(dir)`, `minimap_zoom_about(rx, ry, factor)` | zoom |
| `minimap_view_x()`, `minimap_view_z()`, `minimap_have_view()`, `minimap_centre(x, z)`, `minimap_clamp()`, `minimap_recentre(on_you)`, `minimap_focus(on_you)` | where it looks |
| `minimap_pan_begin(rx, ry)`, `minimap_pan_to(rx, ry)`, `minimap_pan_end()`, `minimap_panning()` | a drag |
| `minimap_pick(rx, ry, r) -> int`, `minimap_placing()`, `minimap_place_toggle()`, `minimap_place(rx, ry, label) -> int` | a press: open the mark under it, or drop the next one there |
| `minimap_reset()`, `minimap_system() -> System` | `"minimap"`: the seen grid, the marks, the followed one and the last symbol in its own section, by key; the view is not saved |

## Tests

```bash
ludic test packages/ludic.minimap
```

A 20 x 20 grid with sea on one side: the cells, revealing and the land's share, the marks' cap,
editing and rubbing out, the nearest for a compass, projection, zoom about a point, a pan, focus
and the clamp, picking and placing, the scale bar, and the save.
