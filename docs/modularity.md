# The module interface

Every module mates on a **rectangular register** plus a **4-corner M3 pattern**, both
defined once in `scad/lib/interface.scad`. Get these right and any module you design will
fit the rest.

## The register

| Feature | Value | Where |
|---|---|---|
| Footprint | `outer_x` × `outer_y` = board + `2·inner_clear` + `2·wall` | `params.scad` (computed) |
| Register footprint | `reg_x` × `reg_y` = outer − `2·reg_inset` (`reg_inset = 6`) | `params.scad` |
| Male boss height | `reg_boss_h` = 2.6 mm | `params.scad` |
| Female pocket depth | `reg_pocket_h` = 3.0 mm | `params.scad` |
| Slip fit (radial) | `reg_fit` = 0.15 mm | `params.scad` |
| Index key | 3 × 6 mm tab on **+X**, so a module only assembles one way | `interface.scad` |

`body` has a **female pocket at both ends**. `front_plate` and `rear_plate` each present a
**male boss**. Screws pull the boss into the pocket; the register takes the shear.

## The bolt pattern

`mate_screw_xy()` → four points at `(±(outer_x/2 − 3.5), ±(outer_y/2 − 3.5))`, i.e. the
corners, inside `corner_ears` (Ø7 bosses). `body` holds an **M3 heat-set insert at each of
the 8 positions** (4 front, 4 rear). Front and rear plates have **clearance holes +
cap-head counterbores**. Screw length: front `M3 × 8`, rear `M3 × 12` (rear cap is thicker).

## Z convention

`z = 0` is the **flange face** (lens seating shoulder). **+Z points into the camera**,
toward the sensor and out the back. Every module is authored in these absolute coordinates,
so `dispatch.scad` can just draw them all together for the assembly view.

## Adding a new module

1. `include <params.scad>; use <interface.scad>; use <util.scad>;`
2. Build your solid in absolute Z. Union `corner_ears(h)` and either `reg_boss()` (if you
   mate to a body pocket) or cut `reg_pocket()` (if a boss mates into you).
3. Cut fasteners with `mate_screws("clear", h)` or `mate_screws("insert-…")`.
4. Add a `part == "yourthing"` branch in `scad/lib/dispatch.scad`.
5. `make check` — the asserts and `--hardwarnings` must stay green.

## Adding a new variant

Copy `scad/variants/generic_29mm_c.scad`, change the overrides (board size, hole pitch,
mount type/style, gland), add the name to `VARIANTS` in the `Makefile` and to
`variants.json`. `make <name>` builds it.

## Parameter override mechanics (important)

`params.scad` uses **plain assignments** so the OpenSCAD Customizer works. A variant file
therefore does `include <../lib/params.scad>` **first**, then re-assigns the few parameters
it pins, then `include <../lib/dispatch.scad>`. OpenSCAD's "last assignment wins" rule makes
the override stick. On the command line, `-D 'name=value'` beats both.
