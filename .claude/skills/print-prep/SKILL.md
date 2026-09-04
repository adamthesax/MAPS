---
name: print-prep
description: Produce a print job sheet for a mapscam variant — the part list with per-part orientation, filament/time estimate, slicer settings, and the fasteners/inserts to have ready. Use when the user says "I want to print this", "prep for printing", "what do I need to print the camera".
---

# Print prep

## Steps
1. Confirm the variant (default `generic_29mm_c`) and material (default PETG).
2. `make <variant>` to ensure `stl/<variant>-*.stl` exist and are current.
3. Produce a job sheet (markdown) with:

### Parts table
| STL | Qty | Orientation | Notes |
|---|---|---|---|
| `<v>-front.stl` | 1 | thread axis **vertical**, lens up | no supports; slow small-perimeter speed |
| `<v>-body.stl` | 1 | either open end up | register pocket bridges ≤3 mm |
| `<v>-carrier.stl` | 1 | floor down, standoffs up | |
| `<v>-rear.stl` | 1 | outer face down | gland hole bridges |
| `<v>-shims.stl` | 1 | flat | fragile; print as one sheet |
| `<v>-base.stl` | 0–1 | flat, countersinks up | only for wall mounts |

### Slicer settings (from `docs/print-settings.md`)
0.16 mm layers · 0.20 mm first layer · 4 perimeters · 5 top/bottom · 30–40% gyroid ·
**no supports** · seam aligned to the rear, off the register and thread ·
XY compensation tuned so an M3 insert pocket measures Ø4.0.

### Hardware to have ready (from `docs/bom.md`)
8× M3 heat-set + 4× M2 heat-set + 1× 1/4"-20 heat-set · 4× M3×8 · 4× M3×12 · 4× M2 ·
(ring build: 3× M2 grub + the metal ring) · PG7 gland · gasket stock · silica gel.

4. Note anything variant-specific (e.g. larger board → longer body → more filament/time).
5. Offer to save the sheet as `docs/print-jobs/<variant>.md`.

## Don't
- Don't recommend supports — parts are oriented to avoid them; if something needs support,
  that's a geometry bug to file, not a slicer setting.
