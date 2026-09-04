# Vibrometer receiver optic

A large-aperture receiver telescope for the M.A.P.S. laser vibrometer
(see [PR #1](https://github.com/adamthesax/MAPS/pull/1) for the vibrometer roadmap).
It is its own component **type** (`components/receiver/*.toml`, `scad/lib/receiver/`),
like `lens`, because none of the camera sensor stack applies.

```
   target  <--- [ Ø80 optic ] === barrel ===|clamp|=== stem ===[ flange ] --- mapscam body --- detector
                 f ≈ 150 mm       (slides)              (fixed)    z = 0        (BPW34 + AFE)
                                                                   808 nm filter in the stem, at the flange
```

The bought **Ø80 mm, f ≈ 150 mm** optic focuses the returned beam through a small
**8 mm 808 nm bandpass filter** onto the detector, which rides on a stock mapscam
`body` bolted to the rear flange (same rectangular register + 4-corner M3 pattern
as a camera `front_plate` — a `generic_29mm` body drops straight on).

## Focus — draw-tube

Focus is the lens-to-detector distance. The wide **`barrel`** (holds the optic)
telescopes over the narrow **`stem`** (fixed to the flange); a **split-clamp collar**
on the barrel pinches the stem with one M3 screw. Slide to focus, tighten to lock.

Default travel: **125 – 175 mm** (`focus_nominal ± focus_travel`), i.e. from a
~1 m target standoff to past infinity. Fine focus beyond that is the camera shim
stack, exactly as for a normal lens.

## Coordinate convention

Mirror of the camera: **`z = 0` is the flange face** that seats on the body, **+Z
runs into the body** (register boss, bolt bosses), the optics project to **−Z**,
out toward the target. `barrel.scad` is authored in its own frame (optic rear face
at `z = 0`); `dispatch.scad` slides it to `−focus_nominal` for the assembly view.

## The stack (enforced in `scad/lib/receiver/params.scad`)

```
pocket_bore   = element_d + 2·element_fit            // Ø80 optic pocket
barrel_len    = focus_nominal − barrel_rear_gap      // optic rear face -> barrel rear face
stem_len      = focus_travel + barrel_rear_gap + collar_len + 8
collar_bore   = draw_od + 2·slide_fit                // barrel collar rides the stem here
```

`assert()`s fail the render if the clear aperture leaves no seat rim, if a wall
(barrel / stem / collar / filter retainer) is thinner than `wall`, if the focus
travel reaches past the flange, or if `focus_nominal` is too short for the barrel.

## Parts (`make vibrometer_80mm`)

| Part | Prints | Notes |
|---|---|---|
| `stem` | 1 | flange + draw tube + 808 nm filter cell. Print flange-down, tube vertical. |
| `barrel` | 1 | Ø90 × ~160 mm. Print collar-up. Big — budget the time / filament. |
| `lens_retainer` | 1 | plain ring, held by the barrel's 3 radial M3 set screws. |
| `filter_ring` | 1 | coarse-thread ring, clamps the filter from the body-cavity side. |

Fasteners: 1 × M3 pinch screw + M3 nut (clamp); 3 × M3 set screws (lens retainer);
4 × M3 into the body inserts (flange, same as a camera front plate).

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
  Fine for qualitative spectra; move it ahead of the focus (into a collimated space)
  if you need the full rejection.
- **Single bearing.** The barrel rides the stem on one 30 mm collar; a second
  bearing near the optic would cut focus wobble.
- **Laser path not included** — receiver only, per the current plan. Bistatic
  transmit mount is a separate part.
