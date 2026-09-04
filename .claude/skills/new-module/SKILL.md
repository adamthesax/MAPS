---
name: new-module
description: Add a whole new printed module to the mapscam stack (e.g. a filter drawer, an IR-cut holder, a lens hood, a Peltier/heatsink back, a PoE-splitter bay) that mates on the shared inter-module interface. Use when the user wants a new physical section of the camera, not just a size tweak.
---

# New module

Read `docs/modularity.md` first — it defines the register, the bolt pattern, and the Z
convention that a new module must honour.

## Contract every module keeps
- Footprint `outer_x` × `outer_y` with `corner_r` rounding.
- `corner_ears(h)` unioned; M3 at `mate_screw_xy()` — clearance+counterbore if it bolts
  onto a neighbour, `heatset` if a neighbour bolts onto it.
- A `reg_boss()` where it plugs into a body-style female pocket, **or** a `reg_pocket()`
  where a boss plugs into it. Keep the +X index key.
- Authored in absolute Z (`z = 0` at the flange face, +Z into the camera). If the module
  adds length between two existing modules, everything downstream shifts — prefer to make
  the shift explicit via a parameter and update the `body_length` derivation, or place the
  module *outside* the optical stack (in front of the flange, or behind the rear cap).

These are camera-enclosure modules — they live in `scad/lib/camera/`. Shared helpers
(`constants.scad`, `util.scad`, `hardware.scad`) stay in `scad/lib/`.

## Steps
1. New file `scad/lib/camera/<module>.scad`: `include <params.scad>; use <interface.scad>;
   use <../util.scad>; use <../hardware.scad>;` then `module <module>() { … }` and a bare
   `<module>();` call at the end.
2. Add any new knobs to `scad/lib/camera/params.scad` (plain assignment, Customizer
   annotation). If it changes the optical stack, extend the "computed" section and the
   `assert()`s.
3. `use <<module>.scad>` + a `part == "<module>"` branch in `scad/lib/camera/dispatch.scad`,
   and place it in the exploded `assembly` preview.
4. Add `<module>` to `parts` / `check_parts` in `components/_type/camera.toml`.
5. `make gen && make check`, then render and read the PNG.
6. Update `docs/modularity.md` (module list), `docs/bom.md`, `README.md` layout.

## Test
`OPENSCADPATH=vendor openscad -o stl/x.stl -D 'part="<module>"' scad/camera.scad` — must be
manifold; `make check` stays green.
