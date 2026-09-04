---
name: add-lens-body
description: Scaffold a new mapscam printed lens barrel — a holder for a bought singlet / achromat / salvaged element group with a male C or CS thread, optional filter thread and hood. Use when the user says "add a lens", "print a lens barrel", "I have a Ø12.7 achromat", "housing for this element", or gives element dimensions and a back-focus number.
---

# Add a lens body

Lens barrels are a component *type*, config-driven: one TOML under `components/lens/`,
expanded by `tools/gen.py`. Modules live in `scad/lib/lens/`. See `docs/components.md` and
the "Lens bodies" section of `docs/design-notes.md`.

## Inputs to collect from the user
- A short slug, e.g. `achromat_12mm_c` (lowercase, underscores). Unique across all components.
- `mount_type` = `C` | `CS` (male thread into the camera front plate).
- `flange_to_rear_vertex` (mm) — flange face → rear vertex of the rearmost element. From
  the lens prescription, or measured back focus. **Critical for focus**; flag it if guessed.
- `element_d` (element OD), `element_edge_thk` (rim / edge thickness = seat depth).
- `element_count` (1–2) and `element_gap` if a spaced pair.
- `clear_aperture_d` — must be ≥ 1 mm smaller than `element_d`.
- Optional: `filter_thread` (`none` | `M25.5x0.5` | `M30.5x0.5` | `M37.5x0.5` | `M40.5x0.5`),
  `hood_style` (`none` | `round`) + `hood_length`, `barrel_od` (0 = auto), `wall`.

## Steps
1. Create `components/lens/<slug>.toml`:
   ```toml
   type  = "lens"
   title = "<element>, <mount>, <filter>"

   [params]
   flange_to_rear_vertex = 8.0
   element_d             = 12.7
   element_edge_thk      = 4.0
   clear_aperture_d      = 10.0
   filter_thread         = "M30.5x0.5"
   ```
   Every `[params]` key must be assigned in `scad/lib/lens/params.scad` or `make gen` fails.
2. `make gen` — writes `scad/variants/<slug>.scad` + wiring.
3. `make check` — on an `assert()` failure read the message in `scad/lib/lens/params.scad`
   (rear vertex inside the thread, no seat rim, wall too thin, filter too small) and adjust
   the TOML, then `make gen`.
4. `make <slug>` — `stl/<slug>-{barrel,retainer,hood}.stl` + `renders/<slug>.png`. Read the
   PNG (bore concentric, rear thread present, retainer seats) and the echoed
   `flange->rear vertex`, `group_thk`, `barrel_od`, `total_track`.
5. Report: the new TOML, the echoed lens stack, any guessed number (especially
   `flange_to_rear_vertex`), and which parts to print.

## Don't
- Don't hand-edit `scad/variants/*.scad` / `components.json` / the README table — generated.
- Don't expect a focus helicoid — barrels are fixed-focus; fine focus is the camera shim
  stack. A moving `focus_ring` is a future addition.
