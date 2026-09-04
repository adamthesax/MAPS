---
name: render-and-qc
description: Render mapscam parts to STL and preview PNG for one or all variants and sanity-check the result — echoed stack dimensions, manifold validity, obvious geometry faults. Use when the user says "render the parts", "build the STLs", "check the model", "does the body look right".
---

# Render & QC

## Render
- If a `components/*.toml` changed, run `make gen` first (or just `make …`, which does it).
- One component, all parts + preview: `make <variant>` (e.g. `make generic_29mm_cs`,
  `make achromat_12mm_c`).
- Everything: `make` (STLs + PNGs) — slow, printed threads take ~1 min each.
- One part ad hoc:
  `OPENSCADPATH=vendor openscad -o stl/x.stl -D 'part="body"' scad/variants/<v>.scad`
  (lens: `-D 'part="barrel"' scad/lens.scad`).
- Cross-section / inspection PNG: add `--camera=…` and `--projection=o`; read the PNG back.

## QC checklist
1. **`make check` is green** — runs `tools/gen.py --check` (generated files current) then
   every component/part with `--hardwarnings`, so any warning or failed `assert()` fails it.
2. **Echoed numbers are sane** —
   - camera: `body_length`, `ledge_z`, `carrier_face_z`. Compare `body_length` to the
     README / `components.json`; a big jump means a parameter is off.
   - lens: `flange->rear vertex`, `group_thk`, `barrel_od`, `total_track`.
3. **Manifold** — for a *single part*, the OpenSCAD log must NOT say "may not be a valid
   2-manifold". (The `assembly` view is allowed to; coincident mating faces, not for export.)
4. **Visual** — read `renders/<variant>.png`.
   - camera: lens bore concentric with the body, register boss/pocket aligned, 4 corner
     screw bosses, rear gland hole, tripod boss on the rear-cap edge, carrier aperture clear.
   - lens: rear male thread present, bore concentric, retainer thread + ring seat, hood
     flare (if any) clears the aperture.
5. **STL sizes** — camera parts other than `front` are ~0.4–0.7 MB; `front` and the lens
   `barrel` (printed thread) are ~1.3–1.5 MB. A threaded part that is tiny means the thread
   didn't generate.

## Report
State: which component(s), `make check` result, the echoed stack numbers, manifold status
per part, and anything visually wrong with a pointer to the file/param.
