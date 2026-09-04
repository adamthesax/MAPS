# Vibrometer receiver optic

A large-aperture receiver telescope for the M.A.P.S. laser vibrometer
(see [PR #1](https://github.com/adamthesax/MAPS/pull/1) for the vibrometer roadmap).
It is its own component **type** (`components/receiver/*.toml`, `scad/lib/receiver/`),
like `lens`, because none of the camera sensor stack applies.

```
  target <-[ Ø80 optic ]== barrel ==(collet)[clamp] stem =(helicoid)= [ flange ]- body - detector
             f ≈ 150 mm    coarse: barrel slides on stem   fine: stem   (fixed)          (BPW34)
                           M4 pinch clamp locks it          rotates on   z = 0
                                                            the flange   808 nm filter here
```

The bought **Ø80 mm, f ≈ 150 mm** optic focuses the returned beam through a small
**8 mm 808 nm bandpass filter** onto the detector, which rides on a stock mapscam
`body` bolted to the rear flange (same rectangular register + 4-corner M3 pattern
as a camera `front_plate` — a `generic_29mm` body drops straight on).

## Focus — two stages

**Coarse: draw-tube + wrap clamp.** The wide **`barrel`** (holds the optic) telescopes
over the narrow **`stem`**. The barrel's rear collar is a **3-slot collet**; a separate
**`clamp`** ring wraps it and one tangential M4 pinch screw squeezes the collet onto
the stem. The clamp ring covers the collet slots, so it also seals the split against
stray light. Range: **125 – 175 mm** (`focus_nominal ± focus_travel`) — ~1 m standoff
to past infinity.

**Fine: printed helicoid.** The **`stem`** threads onto a male boss on the **`flange`**
via a light square-profile helicoid (`scad/lib/receiver/helix.scad` — a
`linear_extrude(twist=…)` thread, far cheaper under CGAL than a BOSL2 `threaded_rod`,
and a square profile prints better on FDM anyway). Grip the knurled stem collar,
rotate for **`fine_travel` = 6 mm** of continuous travel (~2.4 turns at 2.5 mm
pitch), lock with a radial M3 grub in the collar. This moves the whole optical tube
against the body-mounted detector — standard camera-lens focus. Nothing a cable
crosses rotates (the AFE stays on the fixed flange).

## Coordinate convention

Mirror of the camera: **`z = 0` is the flange face** that seats on the body, **+Z
runs into the body** (register boss, bolt bosses, filter, detector), the optics
project to **−Z**, out toward the target. `flange.scad` and `stem.scad` are authored
in this frame at mid fine-travel; `barrel.scad` is authored in its own frame (optic
rear face at `z = 0`) and `dispatch.scad` slides it to `−focus_nominal`.

## The stack (enforced in `scad/lib/receiver/params.scad`)

```
pocket_bore      = element_d + 2·element_fit          // Ø80 optic pocket
barrel_len       = focus_nominal − barrel_rear_gap    // optic rear face -> barrel rear face
stem_len         = focus_travel + barrel_rear_gap + collar_len + 8
collar_bore/_od  = barrel collet bore / OD  (rides the stem; the `clamp` grips the OD)
helix_major      = draw_od + 12                       // fine-focus helicoid Ø
helix_boss_len   = helix_engage + fine_travel + 2     // flange male boss
stem_neck_bot    = stem_top_z − helix_collar_len − neck_len   // draw-tube top
```

`assert()`s fail the render if: the clear aperture leaves no seat rim; a wall
(barrel / stem / collar / filter retainer) is under `wall`; the coarse travel reaches
past the flange; `fine_travel` crashes the stem collar into the flange; the barrel
collet rides onto the stem neck at the far-focus extreme; or `focus_nominal` is too
short for the barrel.

## Parts (`make vibrometer_80mm`)

| Part | Prints | Notes |
|---|---|---|
| `flange` | 1 | body interface + filter cell + male helicoid boss. Print plate-down. |
| `stem` | 1 | female helicoid collar + draw tube. Print collar-up, tube vertical. |
| `barrel` | 1 | Ø90 × ~130 mm; rear collar is a 3-slot collet. Print collar-up. Big. |
| `clamp` | 1 | wrap-around split collar; tangential M4 pinch. Print flat, split-up. |
| `lens_retainer` | 1 | plain ring, held by the barrel's 3 radial M3 set screws. |
| `filter_ring` | 1 | square-thread ring, clamps the filter from the body-cavity side. |

Fasteners: 1 × M4 pinch + M4 nut (clamp); 1 × M3 grub (helicoid lock); 3 × M3 set
screws (lens retainer); 4 × M3 into the body inserts (flange).

## GUESSED numbers — measure and update `components/receiver/vibrometer_80mm.toml`

- `element_edge_thk` — rim thickness of the Ø80 optic (= seat pocket depth).
- `element_sag` — how far the convex face bulges past the rim plane.
- `filter_thk` — thickness of the 8 mm filter.

`focal_length` / `focus_nominal` are set from the optic spec; if the real optic is
not exactly f = 150 mm, set `focus_nominal` to its actual back focus and keep
`focus_travel` wide enough to cover your standoff range.

## Known limitations (v0 — nothing fit-tested)

- **Cantilever.** A Ø90 barrel on a 39 mm flange is floppy held horizontal; plan on
  a ring clamp around the barrel for anything but short bench runs.
- **Filter at the focus.** The 8 mm filter sits ~150 mm from the optic, near focus,
  so marginal rays hit it at up to ~15° — enough to shift a narrow 808 nm passband.
  Fine for qualitative spectra; move it ahead of the focus (into collimated space)
  if you need the full rejection.
- **Stray light via the collet split.** The `clamp` ring covers the collet slots,
  but neither telescoping joint is light-tight. The Ø6 field stop + the 808 nm
  bandpass filter are the real defense; blacken the bores and, in sunlight, wrap
  the clamp. See the notes in `design-notes.md`.
- **Helicoid feel.** A square printed thread at 2.5 mm pitch is coarse and a bit
  notchy; fine for set-and-lock focus, not a silky camera helicoid. `HELIX_FN` /
  `helix_slices` in `helix.scad` trade render time for smoothness.
- **Single bearing.** The barrel rides the stem on one 30 mm collet; a second
  bearing near the optic would cut focus wobble.
- **Laser path not included** — receiver only, per the current plan. Bistatic
  transmit mount is a separate part.
