# Print settings

## Material

| Choice | Why |
|---|---|
| **PETG** (default) | dimensionally stable, low warp, tolerates the warmth near a sensor, cheap |
| **ASA / ABS** | outdoor / UV exposure, higher temp; needs an enclosure to print |
| PLA | prototyping only — creeps under fastener preload and sags if the camera warms |

## Slicer profile

| Setting | Value | Reason |
|---|---|---|
| Layer height | 0.16 mm | Z resolution feeds straight into flange-focal-distance error |
| First layer | 0.20 mm, slow | flat, square datum faces |
| Perimeters / walls | 4 | strong threads, solid insert bosses |
| Top / bottom layers | 5 / 5 | opaque, light-tight |
| Infill | 30–40 % gyroid | |
| Supports | **none by design** — see orientation below | |
| Seam position | rear / aligned, away from the register and thread | |
| Horizontal expansion / XY compensation | tune so an M3 heat-set pocket measures Ø4.0 | |

## Orientation

| Part | Orientation | Note |
|---|---|---|
| `front` | **thread axis vertical**, lens tower up | clean thread, no bridging over the bore |
| `body` | open end up (either end) | register pockets bridge fine at ≤ 3 mm; add a 0.3 mm ledge chamfer if sagging |
| `carrier` | floor down, standoffs up | |
| `rear` | outside face down | gland hole bridges; fine |
| `shims` | flat | print one sheet; they're fragile — handle with tweezers |
| `base` | flat, countersinks up | |

## Post-processing

1. Install heat-set inserts with a soldering iron + insert tip. Press square. Let cool
   before loading.
2. Run a tap / the actual lens through printed threads to clear strings.
3. Test-fit the register (front boss into body pocket) — it should be a firm hand push.
   Too tight: raise `reg_fit`. Too loose: lower it, reprint.

## Dimensional QC before assembly

- Caliper the body length; compare to the `body_length` value `echo`ed at render time.
- Thread ring gauge or the real lens: it should seat without cross-threading.
- Carrier + PCB dry stack height vs. `carrier_face_z − pcb_front_z`.
