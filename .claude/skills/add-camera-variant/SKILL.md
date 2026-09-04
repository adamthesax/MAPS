---
name: add-camera-variant
description: Scaffold a new mapscam camera variant end to end — a new sensor board size, mounting-hole pitch, C/CS mount, printed-thread vs captured-ring, or cable gland. Use when the user says "add a variant", "I have a <sensor> board", "support a 1-inch sensor", or gives new board dimensions.
---

# Add a camera variant

## Inputs to collect from the user
- A short variant slug, e.g. `imx477_38mm_c` (lowercase, underscores).
- Board outline `board_x` × `board_y` (mm).
- Mounting hole pitch `board_hole_pitch_x` / `_y` and hole Ø `board_hole_d`.
- Mount: `mount_type` = `C` | `CS` | `blank`; `lens_mount_style` = `thread` | `ring`.
  - For `ring`: measured ring OD → `ring_bore_d` (+0.1 mm), `ring_depth`, `ring_grubs`.
- `board_to_sensor_surface` (mm) — PCB front face to sensor active surface, **from the
  datasheet**. This is critical for focus; if unknown, flag it and use 2.5 as a placeholder.
- Optional: `gland` (none/PG7/PG9/PG11), `board_thickness`, `standoff_h`.

## Steps
1. Copy `scad/variants/generic_29mm_c.scad` to `scad/variants/<slug>.scad`. Keep the
   `include <../lib/params.scad>` … overrides … `include <../lib/dispatch.scad>` structure.
   Set only the parameters that differ from `scad/lib/params.scad` defaults.
2. Add `<slug>` to the `VARIANTS := …` list in `Makefile`.
3. Add an entry to `variants.json` (`name`, `title`, `overrides` mirroring the .scad file).
4. Add a row to the variant table in `README.md` (name, board, lens mount). Fill the body
   length after step 5.
5. Run `make check`. If an `assert()` fails, read its message in `scad/lib/params.scad`
   (~line 95-100) and adjust `standoff_h` / `board_to_sensor_surface` / `mount_type`.
6. `make <slug>` to produce `stl/<slug>-*.stl` and `renders/<slug>.png`. Read the PNG and
   the `echo`ed `body_length` / `carrier_face_z`; sanity-check them.
7. Report: the new files, the computed body length, any parameter you had to guess
   (especially `board_to_sensor_surface`), and the print/BOM deltas vs. the baseline.

## Don't
- Don't hand-edit `body_length` — it is derived in `params.scad`.
- Don't add parameters to a variant file that already match the defaults.
