# ludic.photo

A camera's photographs: what is in the frame and can be seen, a grade out of a hundred for its best
subject, the roll it goes onto with its tags and order, what each frame is worth to a buyer, and the
best frame yet of every subject. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.photo"
```

The package never reads pixels and never draws. The game offers the subjects and tags of a frame,
reads its picture back and writes the file itself, then keeps it with `photo_keep(file, day, hour)`;
what that means in the game - the life list, the jobs, the words - is the `PHOTO_KEPT` fact.

## The grade

Out of a hundred, for the frame's best subject:

| | |
| --- | --- |
| size (40) | the subject's height as a share of the picture: under 4% a record shot, a quarter to two thirds pays, past 85% cropped |
| framing (20) | how near a thirds point it sits; a subject cut by an edge keeps a third of that (a tripod adds 5) |
| light (20) | the hour after dawn and before dusk best, flat noon middling, the moon at night; the weather's `dim` and `bonus`; backlit costs 7 |
| the moment (20) | what it is doing, as the game scores it (head up and still unaware is worth most) |

Framing, light and the moment are weighted by how much subject there is, so a deer three pixels wide
in perfect light is not a photograph. `PhotoRules.behaviour` halves size and doubles the moment.
**A tag is a tag at any grade**: the grade is what a frame is worth, never whether it happened.
`photo_why(i)` is the worst component (`PHOTO_WHY_SIZE`, `_FRAME`, `_LIGHT`, `_MOMENT`, or `_FINE`),
for the game to word.

## The ports

```ludic
export port PhotoLens {
  x, y, z, fx, fy, fz, fov,                       # the camera
  project(x, y, z) -> bool, sx(), sy(),           # into the picture, 0..1
  visible(x, y, z, r) -> bool,                    # the frustum
  clear(ax, ay, az, bx, by, bz) -> bool,          # a line of sight: the ground and every still thing
  range(), steady() -> bool                       # the lens in the pack
}
export port PhotoLight { hour, night, moon, dim, bonus, sun_x, sun_z }
export port PhotoRules { behaviour, subject_value(sp), legend_value(sp), mult }
```

Every member has a default: a lens at the origin looking down -z with nothing in the way at noon.

## API

| | |
| --- | --- |
| `photo_frame_begin()`, `photo_frame_subject(sp, name, x, y, z, h, legend, moment) -> bool`, `photo_frame_tag(text)`, `photo_frame_sign(n)`, `photo_frame_stars()` | composing: a subject the lens sees is tagged (a kind once, every legend) and scored |
| `photo_pending_tags/mask/legend/grade/why/sign/stars()`, `photo_comp(k)`, `photo_comp_have()` | the frame being composed, for a viewfinder and its meter |
| `photo_in_view(x, y, z, far)`, `photo_score(x, y, z, h, moment)`, `photo_score_size/frame/light` | the parts, for a game's own questions |
| `photo_keep(file, day, hour) -> int`, `photo_add(...)`, `photo_remove(i)`, `photo_cover_set(i)` | the roll: kept (or -1 and `PHOTO_FULL`), added as saved, forgotten (`PHOTO_DELETED` names the file) |
| `photo_count()`, `photo_max()`, `photo_full()`, `photo_day/hour/mask/legend_mask/sold/grade/why/tags/file/graded(i)`, `photo_cover()` | the roll's frames |
| `photo_species_shot()`, `photo_legend_shot()`, `photo_best(sp)`, `photo_record_set`, `photo_best_set` | what was ever photographed (sold or deleted still counts) and the best grade of each subject |
| `photo_band(g)` (0 a record shot .. 4 one for the wall), `photo_grade_mult(g)` (0.35 .. 4) | the grade's bands and its price curve |
| `photo_value(i)`, `photo_worth()`, `photo_sell_all()` | a buyer pays for a subject's first frame and every legend, on the curve; `PHOTO_SOLD` per frame |
| `photo_sort()`, `photo_sort_next()` (`PHOTO_NEWEST`, `_BEST`, `_BY_SUBJECT`), `photo_order()`, `photo_page_list()`, `photo_pages()`, `photo_page_now()`, `photo_page_step(d)` | the roll in order, eight to a page |
| `photo_slug(tags)` | a file name from the tags |
| `photo_facts() -> Queue<PhotoFact>` | `{ what, index, mask, legend, firsts, grade, sign, stars, file, tags, v }`: `PHOTO_KEPT`, `_FULL`, `_DELETED`, `_SOLD` |
| `photo_config(max)`, `photo_reset()`, `photo_system() -> System` | `"photo"`: the frames, the record, the cover and the order in its own section, by key |

## Tests

```bash
ludic test packages/ludic.photo
```

A lens over flat ground with a ridge and a trunk: what is in view, the four parts of the grade, the
frame's best subject and its tags, keeping and the full card, value and selling, forgetting a frame,
the roll's order and pages, file names and the save.
