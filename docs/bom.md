# Bill of materials

Per camera, `generic_29mm_c` baseline. Quantities scale with your board.

## Printed parts

| Part | Qty | `part=` | Notes |
|---|---|---|---|
| Front plate | 1 | `front` | thread-axis vertical on the bed |
| Body | 1 | `body` | length is variant-dependent |
| Sensor carrier | 1 | `carrier` | standoffs up |
| Rear cap | 1 | `rear` | |
| Shim set | 1 sheet | `shims` | 0.1 / 0.1 / 0.2 / 0.2 / 0.5 mm |
| Wall bracket | 0–1 | `base` | optional, for wall/ceiling mounts |
| C↔CS spacer | 0–1 | `spacer` | only if mixing C body with CS lens |

## Fasteners & inserts

| Item | Qty | Spec |
|---|---|---|
| Heat-set insert, M3 × L5 (OD ≈ 4.0) | 8 | body: 4 front + 4 rear |
| Heat-set insert, M2 × L4 (OD ≈ 3.2) | 4 | carrier standoffs (PCB screws) |
| Heat-set insert, 1/4"-20 (OD ≈ 8.0, L10) | 1 | rear cap edge (tripod) |
| Cap screw, M3 × 8 | 4 | front plate → body |
| Cap screw, M3 × 12 | 4 | rear cap → body |
| Screw, M2 × (6–8, per standoff+PCB) | 4 | PCB → carrier |
| Grub screw, M2 × 3 | 3 | **`ring` build only** — retains the metal ring |

## Bought hardware

| Item | Qty | Notes |
|---|---|---|
| Metal C-mount ring / adapter | 1 | **`ring` build only.** Measure OD, set `ring_bore_d`. |
| Cable gland, PG7 (or PG9/PG11) | 1 | matches `gland`; PG7 hole = 12.5 mm |
| Foam or O-ring gasket stock | ~0.3 m | between register faces if you need light/dust sealing |
| Silica gel pack, ~1 g | 1 | fits the rear-cap desiccant pocket |
| C-mount lens | 1 | image circle must cover your sensor diagonal |

## Consumables

- PETG or ASA filament, ~60 g per camera (see [print-settings.md](print-settings.md)).

---

## Lens barrel (`components/lens/*`)

A separate component type — a printed holder for bought glass. Parts: `barrel`, `retainer`,
`hood`.

| Item | Qty | Notes |
|---|---|---|
| Lens element / achromatic doublet | 1 group | Ø set by `element_d`; measure the edge thickness → `element_edge_thk` |
| Printed retainer ring | 1 | `part=retainer`, coarse printed thread, clamps the group back against the seat |
| Printed hood | 0–1 | `part=hood`, threads onto the filter thread or slips over the barrel OD |
| Black paint / flock liner | a little | kill internal reflections in the bore |

No fasteners. Set `flange_to_rear_vertex` from the lens prescription or bench back-focus;
fine focus is the camera's shim stack. `spacer` (C↔CS 5 mm ring) stays a camera part.
