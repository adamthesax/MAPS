# Vibrometer receiver optic

A large-aperture receiver telescope for the M.A.P.S. laser vibrometer
(see [PR #1](https://github.com/adamthesax/MAPS/pull/1) for the vibrometer roadmap).
It is its own component **type** (`components/receiver/*.toml`, `scad/lib/receiver/`),
like `lens`, because none of the camera sensor stack applies.

```
  target <--[ Ø80 optic ]===== barrel =====(socket)[ neck ][ flange ]-- mapscam body -- detector
             f ≈ 150 mm    Ø90 tube, holds the optic   plugs in,    z = 0             (BPW34 + AFE)
                                                       3 screws     808 nm filter here
```

The bought **Ø80 mm, f ≈ 150 mm** optic focuses the returned beam through a small
**8 mm 808 nm bandpass filter** onto the detector, which rides on a stock mapscam
`body` bolted to the rear of the `stem` (same rectangular register + 4-corner M3
pattern as a camera `front_plate` — a `generic_29mm` body drops straight on).

## Fixed focus

This is **one rigid tube**. The `stem` (body interface + filter cell + a short neck)
plugs `join_len` into a socket in the rear of the `barrel` (holds the optic) and is
pinned with **3 radial screws** into a groove in the neck. `flange_to_optic` (flange
face → optic rear face) is fixed at the design value; the camera shim stack takes up
the detector-position slack, same as a normal lens.

**Focus control is a later pass** — most likely by making the element position
inside the `barrel` adjustable (a threaded element cell), which is a small, cheap
part and keeps the load path out of any moving joint.

## Coordinate convention

Mirror of the camera: **`z = 0` is the flange face** that seats on the body, **+Z
runs into the body** (register boss, bolt bosses, filter, detector), the optics
project to **−Z**, out toward the target. `stem.scad` is authored in this frame;
`barrel.scad` is authored in its own frame (optic rear face at `z = 0`) and
`dispatch.scad` places it at `−flange_to_optic`.

## The stack (enforced in `scad/lib/receiver/params.scad`)

```
pocket_bore    = element_d + 2·element_fit             // Ø80 optic pocket
barrel_len     = flange_to_optic − stem_neck_len       // optic rear -> barrel rear face
cone_d(z)      = clear_aperture_d · |z| / flange_to_optic   // the light cone behind the optic
neck_bore      = ceil(cone_d(−stem_neck_len − join_len) + 4) // must clear the cone at the joint
neck_od        = neck_bore + 2·wall
socket_bore    = neck_od + 2·join_fit
```

Why the barrel is most of the tube: the f/1.9 cone is still ~Ø45 only 60 mm behind
the optic, so any tube back there has to be wide. The Ø90 barrel bore carries it
until the cone has shrunk to ~Ø18, ~`stem_neck_len` from the flange — that is where
the narrow `stem` neck takes over. Push `stem_neck_len` up and `neck_bore` grows
with it (asserted); push it down and the neck gets stubby.

`assert()`s fail the render if: the clear aperture leaves no seat rim; a wall
(barrel / stem / socket) is under `wall`; the neck bore vignettes the cone at the
joint; the filter retainer thread doesn't fit the neck bore; or `flange_to_optic`
is too short for the barrel.

## Parts (`make vibrometer_80mm`)

| Part | Prints | Notes |
|---|---|---|
| `stem` | 1 | body interface + filter cell + Ø28 neck. Print flange-down; no support. |
| `barrel` | 1 | Ø90 × ~145 mm; optic cell + tube + rear socket. Print optic-end-down. Big — budget time / filament. |
| `lens_retainer` | 1 | plain ring, held by the barrel's 3 radial M3 set screws. |
| `filter_ring` | 1 | threaded ring, clamps the filter from the body-cavity side. |

Fasteners: 3 × M3 (stem↔barrel joint, tapped into the socket wall); 3 × M3 set
screws (lens retainer); 4 × M3 into the body inserts (flange).

## GUESSED numbers — measure and update `components/receiver/vibrometer_80mm.toml`

- `element_edge_thk` — rim thickness of the Ø80 optic (= seat pocket depth).
- `element_sag` — how far the convex face bulges past the rim plane.
- `filter_thk` — thickness of the 8 mm filter.

`focal_length` / `flange_to_optic` are set from the optic spec; if the real optic is
not exactly f = 150 mm, set `flange_to_optic` to its actual back focus.

## Known limitations (v0 — nothing fit-tested)

- **No focus.** Fixed tube — see above. Fine for a fixed bench standoff; add the
  moving-element cell before you need to work multiple target distances.
- **Cantilever.** A Ø90 barrel on a 39 mm flange is floppy held horizontal; plan on
  a ring clamp around the barrel for anything but short bench runs.
- **Filter near the focus.** The 8 mm filter sits ~150 mm from the optic, near
  focus, so marginal rays hit it at up to ~15° — enough to shift a narrow 808 nm
  passband. Fine for qualitative spectra; move it into collimated space if you need
  the full rejection.
- **Stray light.** The stem↔barrel joint is a slip fit, not light-tight; the Ø6
  field stop + the 808 nm bandpass filter are the real defense. Blacken the bores
  and, in sunlight, tape the joint. See `design-notes.md`.
- **Laser path not included** — receiver only, per the current plan. Bistatic
  transmit mount is a separate part.
