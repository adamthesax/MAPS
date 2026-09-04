# M.A.P.S. — Modular Awesome Photonic System

**`mapscam`** is the camera-enclosure repository of the M.A.P.S. project: a **modular,
3D-printed enclosure system for board-level C-mount CMOS cameras**, for fixed and monitoring
installations. The housing is a short stack of independent printed modules — front (lens),
body, sensor carrier, rear (cabling) — on one shared mechanical interface, so each piece can
be reprinted or swapped as sensors and lenses change.

Parametric [OpenSCAD](https://openscad.org) source. Mechanical + docs only — no firmware.

> **Status: v0.1 scaffold.** The geometry renders, the flange-focal-distance math is
> enforced in code, and every variant passes `make check`. Nothing has been printed and
> fit-checked against hardware yet — treat dimensions as a starting point, not gospel.

![exploded assembly](renders/assembly.png)

## Quick start

```bash
git clone --recurse-submodules <this repo>
cd mapscam
brew install openscad          # or apt / your package manager
make check                     # render every variant/part, fail on any warning
make                           # STLs + preview PNGs into stl/ and renders/
```

Render a single part:

```bash
OPENSCADPATH=vendor openscad -o stl/body.stl -D 'part="body"' scad/variants/generic_29mm_c.scad
```

Or open `scad/camera.scad` in the OpenSCAD GUI and use the **Customizer**.

## Variants

| Name | Board | Lens mount | Body length |
|---|---|---|---|
| `generic_29mm_c` | 29 × 29 mm | C, printed 1"-32 thread | 26.6 mm |
| `generic_29mm_c_ring` | 29 × 29 mm | C, captured metal ring | 26.6 mm |
| `generic_29mm_cs` | 29 × 29 mm | CS, printed thread | 21.6 mm |

Add your own: copy `scad/variants/generic_29mm_c.scad`, edit the overrides, add it to
`VARIANTS` in the `Makefile` and to `variants.json`. See
[docs/modularity.md](docs/modularity.md).

## The idea in one table

| | C-mount | CS-mount |
|---|---|---|
| Thread | 1.000"-32 UN | 1.000"-32 UN |
| Flange focal distance (flange → sensor) | **17.526 mm** | **12.526 mm** |

`scad/lib/params.scad` does **not** let you set the body length — it *solves* it from that
flange focal distance, your sensor's PCB-to-active-surface number, standoff height, and a
shim allowance, then `assert()`s the stack is physically possible. A printable shim set
(`part = "shims"`) takes up the ± tolerance for back focus.

## Print checklist (per camera)

`front` · `body` · `carrier` · `rear` · `shims` — plus `base` if wall-mounting.
Fasteners, inserts, gland: [docs/bom.md](docs/bom.md).
Material and orientation: [docs/print-settings.md](docs/print-settings.md).

## Repo layout

```
scad/
  camera.scad          Customizer entry point
  lib/
    constants.scad     C/CS optics, thread spec, fastener dims
    params.scad        every tunable + the derived stack budget + asserts
    interface.scad     the shared inter-module register & bolt pattern
    c_mount.scad       printed thread OR captured-ring interface
    front_plate.scad  body.scad  sensor_carrier.scad  rear_plate.scad
    base_mount.scad    shims.scad
    dispatch.scad      part selector
  variants/            named builds
docs/                  design notes, modularity, BOM, print, assembly, calibration
vendor/BOSL2/          threading & helpers (git submodule)
```

## Skills

`.claude/skills/` holds repo-specific [Claude Code](https://claude.com/claude-code) skills
for common jobs — adding a sensor variant, rendering/QC, print prep, tuning back focus.
See [.claude/skills/README.md](.claude/skills/README.md).

## Licence

OpenSCAD sources and tooling: **MIT** ([LICENSE](LICENSE)).
Docs and renders: **CC-BY-4.0** ([LICENSE-docs](LICENSE-docs)).
Vendored BOSL2: BSD-2-Clause (`vendor/BOSL2/LICENSE`).
