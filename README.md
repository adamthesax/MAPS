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
python3 --version              # 3.11+ (needed by tools/gen.py — stdlib only)
make check                     # regen check + render every component/part, fail on any warning
make                           # STLs + preview PNGs into stl/ and renders/
```

Render a single part:

```bash
OPENSCADPATH=vendor openscad -o stl/body.stl -D 'part="body"' scad/variants/generic_29mm_c.scad
```

Or open `scad/camera.scad` (or `scad/lens.scad`) in the OpenSCAD GUI and use the
**Customizer**.

## Components

Every buildable thing — a camera enclosure, a printed lens barrel — is one small TOML file
under [`components/`](components/). `tools/gen.py` (run by `make gen`, and automatically by
`make`) expands each into a `scad/variants/<name>.scad` stub plus the Make wiring. **The
TOML is the source of truth**; the `.scad` stubs and `components.json` are generated — do
not hand-edit them. See [docs/components.md](docs/components.md).

<!-- BEGIN GENERATED:components -->
### Camera components

| Variant | Description |
|---|---|
| `generic_29mm_c` | 29 mm board, C-mount, printed thread |
| `generic_29mm_c_ring` | 29 mm board, C-mount, captured metal ring |
| `generic_29mm_cs` | 29 mm board, CS-mount, printed thread |

### Lens components

| Variant | Description |
|---|---|
| `achromat_12mm_c` | Ø12.7 achromat barrel, C-mount, M30.5 filter |
<!-- END GENERATED:components -->

Add your own: drop a TOML in `components/camera/` or `components/lens/`, run `make gen`,
then `make check`. See [docs/components.md](docs/components.md) and the `add-camera-variant`
/ `add-lens-body` skills.

## The idea in one table

| | C-mount | CS-mount |
|---|---|---|
| Thread | 1.000"-32 UN | 1.000"-32 UN |
| Flange focal distance (flange → sensor) | **17.526 mm** | **12.526 mm** |

`scad/lib/camera/params.scad` does **not** let you set the body length — it *solves* it from
that flange focal distance, your sensor's PCB-to-active-surface number, standoff height, and
a shim allowance, then `assert()`s the stack is physically possible. A printable shim set
(`part = "shims"`) takes up the ± tolerance for back focus.

## Print checklist (per camera)

`front` · `body` · `carrier` · `rear` · `shims` — plus `base` if wall-mounting.
Fasteners, inserts, gland: [docs/bom.md](docs/bom.md).
Material and orientation: [docs/print-settings.md](docs/print-settings.md).

## Repo layout

```
components/            SOURCE OF TRUTH — one TOML per component (+ _type/ defs)
tools/gen.py           expands components/*.toml -> variant stubs + build wiring
scad/
  camera.scad          Customizer entry point (camera type)
  lens.scad            Customizer entry point (lens type)
  lib/
    constants.scad     shared: C/CS optics, thread spec, fastener dims, filter threads
    util.scad  hardware.scad         shared helpers
    camera/            params · dispatch · interface · front_plate · body ·
                       sensor_carrier · rear_plate · base_mount · shims · c_mount
    lens/              params · dispatch · barrel · retainer · hood
  variants/            GENERATED stubs (committed) — do not hand-edit
components.json         GENERATED manifest (committed)
docs/                  components, design notes, modularity, BOM, print, assembly, calibration
vendor/BOSL2/          threading & helpers (git submodule)
```

## Skills

`.claude/skills/` holds repo-specific [Claude Code](https://claude.com/claude-code) skills
for common jobs — adding a camera variant or a lens body, rendering/QC, print prep, tuning
back focus. See [.claude/skills/README.md](.claude/skills/README.md).

## Licence

OpenSCAD sources and tooling: **MIT** ([LICENSE](LICENSE)).
Docs and renders: **CC-BY-4.0** ([LICENSE-docs](LICENSE-docs)).
Vendored BOSL2: BSD-2-Clause (`vendor/BOSL2/LICENSE`).
