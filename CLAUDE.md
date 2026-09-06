# CLAUDE.md

## What this repo is

`mapscam` is the camera-enclosure repo of **M.A.P.S. (Modular Awesome Photonic System)**.
Parametric OpenSCAD source for a modular 3D-printed enclosure for board-level C-mount CMOS
cameras (fixed / monitoring use). Mechanical design + docs only, no firmware.
Read `README.md` and `docs/design-notes.md` for the full picture.

The repo also hosts M.A.P.S. instrument #2, a **BPW34 laser vibrometer**, as a component
type (`camera` · `lens` · `receiver` · `vibrometer`). The vibrometer **is the stock
`generic_29mm_c` enclosure** — same `front`/`body`/`carrier`/`rear`/`base`/`shims`,
C-mount front and all — with the CMOS sensor PCB swapped for a printed `laser_board`
(`scad/lib/vibrometer/laser_board.scad`) on the carrier standoffs. Plus two non-SCAD
top-level trees — `elec/` (board design) and `sw/` (Python acquisition/analysis +
`sw/firmware/` for a Teensy/RP2040 DAQ). The "no firmware" rule is scoped to `scad/lib/`.
See `docs/vibrometer/`.

## Build

```bash
make check        # CI gate: every variant/part with --hardwarnings + asserts. Run before committing.
make              # all STLs + preview PNGs
make <variant>    # one variant, e.g. make generic_29mm_cs
```

OpenSCAD needs BOSL2 on its path: the `Makefile` exports `OPENSCADPATH=$(CURDIR)/vendor`.
For ad hoc CLI runs, set it yourself. BOSL2 is a git submodule (`make vendor` to init).

## Invariants — do not break these

1. **`body_length` is derived, never set.** It falls out of the flange-focal-distance stack
   in `scad/lib/params.scad` ("computed" section). Change the inputs (`board_to_sensor_surface`,
   `standoff_h`, `mount_type`, …), not the result.
2. **The three `assert()`s in `params.scad` must stay meaningful.** They catch impossible
   sensor stacks. `make check` relies on them.
3. **The module interface is law.** `scad/lib/interface.scad` defines the register + bolt
   pattern + Z convention shared by front/body/rear. New modules honour it — see
   `docs/modularity.md`.
4. **`params.scad` uses plain assignments** so the Customizer works. Variants override by
   `include params` → re-assign → `include dispatch`. CLI overrides via `-D`.
5. **Parts must render 2-manifold individually.** The `assembly` view may not (coincident
   mating faces) — it's preview only, not for STL export.
6. **The vibrometer is a camera with a different sensor board.** No
   `scad/lib/camera/params.scad` edits: `scad/lib/vibrometer/params.scad` `include`s it
   unchanged, so the enclosure is `generic_29mm_c` exactly (`body_length` 26.626 mm).
   `scad/lib/vibrometer/dispatch.scad` `use`s the stock camera `front_plate` / `body` /
   `sensor_carrier` / `rear_plate` / `base_mount` / `shims`; the only new part is
   `laser_board` (peer of the CMOS PCB — same `board_hole_pitch` M2 pattern, back face at
   `pcb_back_z`). Its own knobs live in `vibrometer/params.scad` and reach `laser_board.scad`
   via a direct `include`; per the variant-override bug they do **not** reach the reused
   camera modules, so the enclosure can't be re-dimensioned from the vibrometer TOML.

## Layout

`scad/camera.scad` entry · `scad/lib/*.scad` modules · `scad/variants/*.scad` named builds ·
`docs/*` guides · `.claude/skills/*` repo skills · `vendor/BOSL2` submodule ·
`stl/` + `renders/` build output.

Vibrometer (instrument #2): `scad/lib/vibrometer/{params,dispatch,laser_board,vib_optics_mounts}.scad`
· `scad/vibrometer.scad` entry · `components/_type/vibrometer.toml` +
`components/vibrometer/*.toml` · `elec/{afe,laser}/` · `sw/vibrometer/` + `sw/firmware/` ·
`docs/vibrometer/`.

## Status

v0.1 scaffold — renders and math check out; nothing printed/fit-tested against hardware yet.
