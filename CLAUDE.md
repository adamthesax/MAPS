# CLAUDE.md

## What this repo is

`mapscam` is the camera-enclosure repo of **M.A.P.S. (Modular Awesome Photonic System)**.
Parametric OpenSCAD source for a modular 3D-printed enclosure for board-level C-mount CMOS
cameras (fixed / monitoring use). Mechanical design + docs only, no firmware.
Read `README.md` and `docs/design-notes.md` for the full picture.

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

## Layout

`scad/camera.scad` entry · `scad/lib/*.scad` modules · `scad/variants/*.scad` named builds ·
`docs/*` guides · `.claude/skills/*` repo skills · `vendor/BOSL2` submodule ·
`stl/` + `renders/` build output.

## Status

v0.1 scaffold — renders and math check out; nothing printed/fit-tested against hardware yet.
