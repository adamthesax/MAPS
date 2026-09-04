---
name: add-camera-variant
description: Scaffold a new mapscam camera variant end to end — a new sensor board size, mounting-hole pitch, C/CS mount, printed-thread vs captured-ring, or cable gland. Use when the user says "add a variant", "I have a <sensor> board", "support a 1-inch sensor", or gives new board dimensions.
---

# Add a camera variant

Variants are config-driven: one TOML file under `components/camera/`, expanded by
`tools/gen.py`. See `docs/components.md`.

## Inputs to collect from the user
- A short variant slug, e.g. `imx477_38mm_c` (lowercase, underscores). Unique across all
  components.
- Board outline `board_x` × `board_y` (mm).
- Mounting hole pitch `board_hole_pitch_x` / `_y` and hole Ø `board_hole_d`.
- Mount: `mount_type` = `C` | `CS` | `blank`; `lens_mount_style` = `thread` | `ring`.
  - For `ring`: measured ring OD → `ring_bore_d` (+0.1 mm), `ring_depth`, `ring_grubs`.
- `board_to_sensor_surface` (mm) — PCB front face to sensor active surface, **from the
  datasheet**. Critical for focus; if unknown, flag it and use 2.5 as a placeholder.
- Optional: `gland` (none/PG7/PG9/PG11), `board_thickness`, `standoff_h`.

## Steps
1. Create `components/camera/<slug>.toml`:
   ```toml
   type  = "camera"
   title = "<board>, <mount>, <thread|ring>"

   [params]
   # only the parameters that differ from scad/lib/camera/params.scad defaults
   mount_type       = "C"
   board_x          = 38
   ```
   Every `[params]` key must be a variable assigned in `scad/lib/camera/params.scad` or
   `make gen` fails.
2. `make gen` — writes `scad/variants/<slug>.scad`, updates `components.json` and the README
   table. Do **not** hand-edit those.
3. `make check` — if an `assert()` fails, read its message in `scad/lib/camera/params.scad`
   (~line 98-103) and adjust `standoff_h` / `board_to_sensor_surface` / `mount_type` in the
   TOML, then `make gen` again.
4. `make <slug>` — produces `stl/<slug>-*.stl` and `renders/<slug>.png`. Read the PNG and
   the `echo`ed `body_length` / `carrier_face_z`; sanity-check them.
5. Report: the new TOML, the computed body length, any parameter you had to guess
   (especially `board_to_sensor_surface`), and the print/BOM deltas vs. the baseline.

## Don't
- Don't hand-edit `scad/variants/*.scad`, `components.json`, or the README table — they are
  generated. Edit the TOML and run `make gen`.
- Don't hand-edit `body_length` — it is derived in `params.scad`.
- Don't add params to a TOML that already match the `params.scad` defaults.
