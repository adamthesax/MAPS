# Vibrometer receiver optic

A large-aperture receiver telescope for the M.A.P.S. laser vibrometer
(see [PR #1](https://github.com/adamthesax/MAPS/pull/1) for the vibrometer roadmap).
It is its own component **type** (`components/receiver/*.toml`, `scad/lib/receiver/`),
like `lens`, because none of the camera sensor stack applies.

```
  target <--[ Ø80 optic ]===== barrel =====(socket)[ neck + filter cell ][ 1"-32 ]-- camera -- detector
             f ≈ 150 mm    Ø90 tube, holds the optic   plugs in, 3 screws    thread  z = 0   (BPW34 + AFE)
                                                       808 nm filter lives here (all -Z of z=0)
```

The bought **Ø80 mm, f ≈ 150 mm** optic focuses the returned beam through a small
**8 mm 808 nm bandpass filter** onto the detector, which rides on a stock mapscam
camera.

## Camera interface — `mount`

**`mount = "C"` (default).** The `stem` ends in a **male 1"-32 thread** and screws
straight into a stock `generic_29mm_c` front plate (`lens_mount_style = "thread"`) —
the receiver is just a C-mount lens, no custom front plate. A Ø`shoulder_d` disc
gives a finger grip and backstops the thread. **Nothing of the receiver reaches past
the seating plane into the camera** — the bare thread is all that goes +Z, and the
whole filter cell sits at -Z inside the neck root (see below). So the receiver is a
clean C-mount citizen: it drops onto any C-mount camera, and mapscam body variants
can put anything they like right behind the front plate. It seats the same way a
mapscam printed C-mount lens does; the camera shim stack trims focus. A Ø90 barrel
on a printed 1"-32 thread is a long cantilever — plan on a barrel brace for anything
but short bench runs, and a dab of thread-locker or a set screw so it can't back off
under vibration.

**`mount = "flange"`.** The `stem` carries its own front plate — the same
rectangular register + 4-corner M3 pattern as a camera `front_plate` (a bare
`generic_29mm` body bolts straight on). Use this when you want the stiff bolted
joint or a keyed orientation. Set `body_outer_x` / `body_outer_y` to that body's
footprint. Same filter cell, same "nothing into the cavity" rule.

## Fixed focus

This is **one rigid tube**. The `stem` (camera interface + filter cell + a short neck)
plugs `join_len` into a socket in the rear of the `barrel` (holds the optic) and is
pinned with **3 radial screws** into a groove in the neck. `flange_to_optic`
(seating plane → optic rear face) is fixed at the design value; the camera shim stack
takes up the detector-position slack, same as a normal lens.

**Focus control is a later pass** — most likely by making the element position
inside the `barrel` adjustable (a threaded element cell), which is a small, cheap
part and keeps the load path out of any moving joint.

## Coordinate convention

Mirror of the camera: **`z = 0` is the seating plane** (the `"C"` shoulder, or the
`"flange"` front face) that meets the camera. Only the **bare thread** goes **+Z**
(then the camera's own detector); the **filter cell and the optics are all at −Z**,
out toward the target. `stem.scad` is authored in this frame; `barrel.scad` is
authored in its own frame (optic rear face at `z = 0`) and `dispatch.scad` places it
at `−flange_to_optic`.

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
joint; the retainer thread + wall don't fit the stem neck; the filter cell runs
into the stem↔barrel joint; `thread_bore_d` leaves too little wall on the male
thread; or `flange_to_optic` is too short for the barrel.

## Parts (`make vibrometer_80mm`)

| Part | Prints | Notes |
|---|---|---|
| `stem` | 1 | camera interface (`"C"` male 1"-32 + grip shoulder, or `"flange"` register) + filter cell in the neck root + Ø28 neck. Print shoulder/flange-down; no support. |
| `barrel` | 1 | Ø90 × ~145 mm; optic cell + tube + rear socket. Print optic-end-down. Big — budget time / filament. |
| `lens_retainer` | 1 | plain ring, held by the barrel's 3 radial M3 set screws. |
| `filter_ring` | 1 | top-hat: a Ø8.1 nose drops onto the filter, the Ø17 threaded body engages the stem. Turn from the −Z (barrel) end. |

## 808 nm filter cell

The filter is **Ø8.0 × 0.55 mm glass** (808 nm narrow band-pass, CWL 808 ± 2 nm,
HBW 25 nm, T > 85 %). The whole cell is cut into the **stem neck root, entirely on
the −Z (target/barrel) side of the seating plane** — nothing projects toward the
camera past the bare thread, so any body variant is free to put hardware right
behind the front plate.

Reading −Z from the seating plane (`z = 0`):

```
[ Ø thread_bore_d clear bore, through the thread ]   z = 0 .. thread_engage  (+Z, toward detector)
[ Ø6 field-stop / seat land ]                        z = -0.8 .. 0
[ Ø8.0 filter ]  seats +Z-face-up on the land        z = -1.35 .. -0.8
[ filter_ring Ø8.1 nose ]                            z = -3.35 .. -1.35
[ funnel Ø8.6 -> Ø17 ]                               z = -3.35 .. -1.85
[ Ø17 retainer thread ]  filter_ring body            z = -6.85 .. -3.35
[ ring lead-in -> neck bore Ø22 -> barrel ]          z < -6.85
```

The **`filter_ring`** is a top hat: Ø8.1 nose, Ø17 threaded body, Ø6 through-bore
(the clear aperture). Drop the filter into the pocket from the **−Z (barrel) end**,
then wind the ring in behind it with a long flat screwdriver down the Ø22 neck bore
(turn it before you plug the barrel on). It seats when the **`fring_nose_h` = 2.0 mm
nose meets the filter face at the same instant the ring body shoulder bottoms on the
funnel step** — so the filter is captured with *zero* clamping stress on the thin
glass while the thread carries its full `fring_engage` (3.5 mm) engagement.

The filter sits ~1 mm target-side of focus. At ~150 mm from a Ø74 aperture the
marginal ray hits it at ≤ 14° — a ~2.5 nm passband shift against a 25 nm half-width,
negligible (the angle is set by aperture ÷ focal length, so the ±few mm of position
doesn't matter).

Fasteners: 3 × M3 (stem↔barrel joint, tapped into the socket wall); 3 × M3 set
screws (lens retainer); `"flange"` only: 4 × M3 into the body inserts.

## GUESSED numbers — measure and update `components/receiver/vibrometer_80mm.toml`

- `element_edge_thk` — rim thickness of the Ø80 optic (= seat pocket depth).
- `element_sag` — how far the convex face bulges past the rim plane.

The filter is spec'd (Ø8.0 × 0.55 mm). `focal_length` / `flange_to_optic` are set
from the optic spec; if the real optic is not exactly f = 150 mm, set
`flange_to_optic` to its actual back focus.

## Known limitations (v0 — nothing fit-tested)

- **No focus.** Fixed tube — see above. Fine for a fixed bench standoff; add the
  moving-element cell before you need to work multiple target distances.
- **Cantilever.** A Ø90 barrel on a printed 1"-32 thread (`mount = "C"`) or a 39 mm
  flange is floppy held horizontal, and a thread can back off under vibration. Plan
  on a brace around the barrel for anything but short bench runs, and thread-locker
  or a set screw on the C-mount joint. `mount = "flange"` gives the stiffer joint.
- **Filter near the focus.** The 8 mm filter sits ~150 mm from the optic, near
  focus, so marginal rays hit it at up to ~15° — enough to shift a narrow 808 nm
  passband. Fine for qualitative spectra; move it into collimated space if you need
  the full rejection.
- **Stray light.** The stem↔barrel joint is a slip fit, not light-tight; the Ø6
  field stop + the 808 nm bandpass filter are the real defense. Blacken the bores
  and, in sunlight, tape the joint. See `design-notes.md`.
- **Laser path not included** — receiver only, per the current plan. Bistatic
  transmit mount is a separate part.
