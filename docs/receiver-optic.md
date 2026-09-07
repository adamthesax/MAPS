# Vibrometer receiver optic

A large-aperture receiver telescope for the M.A.P.S. laser vibrometer
(see [PR #1](https://github.com/adamthesax/MAPS/pull/1) for the vibrometer roadmap).
It is its own component **type** (`components/receiver/*.toml`, `scad/lib/receiver/`),
like `lens`, because none of the camera sensor stack applies.

```
  target <--[ Ø80 optic ]===== barrel =====(socket)[ neck ][ 1"-32 ]-- generic_29mm_c -- detector
             f ≈ 150 mm    Ø90 tube, holds the optic   plugs in,   thread   camera        (BPW34 + AFE)
                                                       3 screws   z = 0   808 nm filter here
```

The bought **Ø80 mm, f ≈ 150 mm** optic focuses the returned beam through a small
**8 mm 808 nm bandpass filter** onto the detector, which rides on a stock mapscam
camera.

## Camera interface — `mount`

**`mount = "C"` (default).** The `stem` ends in a **male 1"-32 thread** and screws
straight into a stock `generic_29mm_c` front plate (`lens_mount_style = "thread"`) —
the receiver is just a C-mount lens, no custom front plate. A Ø`shoulder_d` disc
gives a finger grip and backstops the thread; the slim filter cell (Ø`filter_boss_d_c`
≈ 15) passes through the front-plate's Ø16 bore and noses a few mm into the body
cavity. It seats the same way a mapscam printed C-mount lens does; the camera shim
stack trims focus. Thread this on **before** plugging the heavy `barrel` onto the
neck. A Ø90 barrel on a printed 1"-32 thread is a long cantilever — plan on a barrel
brace for anything but short bench runs, and a dab of thread-locker or a set screw so
it can't back off under vibration.

**`mount = "flange"`.** The `stem` carries its own front plate — the same
rectangular register + 4-corner M3 pattern as a camera `front_plate` (a bare
`generic_29mm` body bolts straight on). Use this when you want the stiff bolted
joint or a keyed orientation. Set `body_outer_x` / `body_outer_y` to that body's
footprint.

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
`"flange"` front face) that meets the camera, **+Z runs into the camera** (thread,
filter cell, detector), the optics project to **−Z**, out toward the target.
`stem.scad` is authored in this frame; `barrel.scad` is authored in its own frame
(optic rear face at `z = 0`) and `dispatch.scad` places it at `−flange_to_optic`.

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
joint; the filter retainer thread doesn't fit the neck bore; `flange_to_optic`
is too short for the barrel; or (`mount = "C"`) the filter cell is too fat to clear
a stock Ø16 front-plate bore.

## Parts (`make vibrometer_80mm`)

| Part | Prints | Notes |
|---|---|---|
| `stem` | 1 | camera interface (`"C"` male 1"-32 + grip shoulder, or `"flange"` register) + filter cell + Ø28 neck. Print shoulder/flange-down; no support. |
| `barrel` | 1 | Ø90 × ~145 mm; optic cell + tube + rear socket. Print optic-end-down. Big — budget time / filament. |
| `lens_retainer` | 1 | plain ring, held by the barrel's 3 radial M3 set screws. |
| `filter_ring` | 1 | top-hat: a Ø8.1 nose drops onto the filter, the threaded body engages the stem. Turn from the body side. |

## 808 nm filter cell

The filter is **Ø8.0 × 0.55 mm glass** (808 nm narrow band-pass, CWL 808 ± 2 nm,
HBW 25 nm, T > 85 %). It drops into a Ø8.6 pocket from the body-cavity side and
seats front-face-down on the **Ø6 field stop shoulder** (`filter_clear_d`, which is
also the FOV stop).

The **`filter_ring`** is a top hat. The stem bore above the seat, going toward the
body, is: `Ø8.6 pocket` → `funnel` → `Ø`fring_d` internal thread` → clearance → out
the boss top. Drop the ring in nose-first from the body side and turn it with a flat
screwdriver (top slot): its threaded body catches the stem thread and winds down. It
seats when the **`fring_nose_h` = 2.0 mm nose meets the filter back face at the same
instant the body shoulder bottoms on the funnel step** — so the filter is captured
with *zero* clamping stress on the thin glass while the thread carries its full
`fring_engage` engagement. A funnel at the pocket mouth centres the nose; the ring's
Ø6 bore is the clear aperture. Assemble the whole cell before mounting the stem on
the camera.

The cell diameter (`filter_boss_d_c`) is set by `mount`:

| `mount` | thread `fring_d` | cell Ø | where the cell sits |
|---|---|---|---|
| `"C"` | 11.5 (1.25 mm pitch) | ~15 | passes the Ø16 front-plate bore, noses a few mm into the cavity |
| `"flange"` | 17 (1.5 mm pitch) | ~23 | projects ~7 mm into the body cavity |

Either way the filter itself sits at z ≈ 2 mm — surrounded by the thread, not moved
off focus. Check the cell clears your AFE PCB / carrier ledge. At ~150 mm from a Ø74
aperture the marginal ray hits the filter at ≤ 14°, a ~2.5 nm passband shift against
a 25 nm half-width — negligible.

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
