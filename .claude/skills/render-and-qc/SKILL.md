---
name: render-and-qc
description: Render mapscam parts to STL and preview PNG for one or all variants and sanity-check the result — echoed stack dimensions, manifold validity, obvious geometry faults. Use when the user says "render the parts", "build the STLs", "check the model", "does the body look right".
---

# Render & QC

## Render
- One variant, all parts + preview: `make <variant>` (e.g. `make generic_29mm_cs`).
- Everything: `make` (STLs + PNGs) — slow, printed threads take ~1 min each.
- One part ad hoc:
  `OPENSCADPATH=vendor openscad -o stl/x.stl -D 'part="body"' scad/variants/<v>.scad`
- Cross-section / inspection PNG: add `--camera=…` and `--projection=o`; read the PNG back.

## QC checklist
1. **`make check` is green** — this runs every variant/part with `--hardwarnings`, so any
   warning or failed `assert()` fails it.
2. **Echoed numbers are sane** — each render prints `body_length`, `ledge_z`,
   `carrier_face_z`. Compare `body_length` to the README table; a big jump means a
   parameter is off.
3. **Manifold** — for a *single part*, the OpenSCAD log must NOT say "may not be a valid
   2-manifold". (The `assembly` view is allowed to; it's coincident mating faces, not for
   export.)
4. **Visual** — read `renders/<variant>.png`. Check: lens bore concentric with the body,
   register boss/pocket aligned, 4 corner screw bosses present, rear gland hole present,
   tripod boss on the rear-cap edge, carrier aperture clear.
5. **STL sizes** — parts other than `front` are ~0.4–0.7 MB; `front` (printed thread) is
   ~1.5 MB. A `front` that is tiny means the thread didn't generate.

## Report
State: which variant(s), `make check` result, the echoed stack numbers, manifold status
per part, and anything visually wrong with a pointer to the file/param.
