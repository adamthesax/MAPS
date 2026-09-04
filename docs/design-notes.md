# Design notes

## What this is

The camera enclosure of **M.A.P.S. (Modular Awesome Photonic System)** — a modular,
3D-printed enclosure for **bare board-level CMOS camera modules** with a
**C-mount** (or CS-mount) lens interface, intended for **fixed / monitoring** installs.
"Modular" here means the enclosure is a short **stack of independent printed modules** on
one shared mechanical interface:

```
   lens ── [ front_plate ] ── [ body ] ── [ rear_plate ] ── cable
                                 │
                            [ sensor_carrier ]  (holds the PCB, shimmed)
```

Any front pairs with any body pairs with any rear, because they all carry the same
rectangular register + 4-corner M3 pattern (see [modularity.md](modularity.md)).

## The optical constraints that drive every dimension

| Quantity | C-mount | CS-mount | Source |
|---|---|---|---|
| Thread | 1.000"-32 UN | 1.000"-32 UN | `CMOUNT_MAJOR_D`, `CMOUNT_PITCH` in `scad/lib/constants.scad` |
| Flange focal distance (flange face → sensor plane) | **17.526 mm** | **12.526 mm** | `C_MOUNT_FFD`, `CS_MOUNT_FFD` |
| C ↔ CS difference | — | 5.000 mm | printed `spacer` part, or shorter body |

Thread pitch 1"/32 = **0.79375 mm**. That is tight for FDM; the `ring` build exists for
when a printed thread is not accurate or durable enough.

### The stack budget (enforced in code)

`scad/lib/params.scad` derives the body length instead of letting you set it:

```
sensor_z       = FFD                                   // target: sensor surface lands here
pcb_front_z    = sensor_z - board_to_sensor_surface    // datasheet number
pcb_back_z     = pcb_front_z + board_thickness
carrier_face_z = pcb_back_z + standoff_h               // carrier floor
ledge_z        = carrier_face_z - shim_nominal         // body ledge, shimmed
body_length    = carrier_back_z + rear_margin + rear_reg_h - front_mate_z
```

Three `assert()`s fail the render (and `make check`) if the geometry is impossible:
sensor stack landing into the body front face, negative body length, or board mounting
holes falling off the carrier.

Every render also `echo`s the resulting `body_length`, `ledge_z`, and `carrier_face_z` so
you can sanity-check against a caliper.

### Tolerance budget (target, not yet measured on prints)

| Contributor | Budget |
|---|---|
| FFD nominal | 17.526 mm |
| Printed-thread datum vs. model | ± 0.15 mm (see `thread_clearance`) |
| Body length Z (layer height, first-layer squish) | ± 0.15 mm |
| Carrier + standoff Z | ± 0.10 mm |
| **Take-up range needed from shims** | **≈ ± 0.5 mm** |

Hence the printable shim set (`part = "shims"`, values `0.1 / 0.1 / 0.2 / 0.2 / 0.5`) plus
`shim_nominal = 0.6` designed in, so you can *remove* shims as well as add them.
Fine adjustment beyond that = focus ring on the lens.

## Printed thread vs. captured ring

| | `lens_mount_style = "thread"` | `lens_mount_style = "ring"` |
|---|---|---|
| Bought parts | none | one metal C-mount extension/adapter ring |
| FFD repeatability | print-dependent, tune `thread_clearance` | set by the metal part |
| Durability | flanks wear with lens swaps | good |
| Print time | slow (~1 min/part, big STL) | fast |
| Notes | print front plate thread-axis vertical | set `ring_bore_d` to measured OD + ~0.1 mm |

## Lens bodies

`mapscam` also prints **lens barrels** — a holder for bought glass (a singlet, an
achromatic doublet, a salvaged element group) with a male C/CS thread on the back. It is a
separate component *type* (`components/lens/*.toml`, `scad/lib/lens/`), not a camera
variant, because nothing about the sensor stack applies.

Coordinate convention mirrors the camera: **`z = 0` is the flange face** (the shoulder that
seats against the camera front plate), **+Z points toward the front of the lens**, and the
male 1"-32 thread runs `z = -thread_engage … 0` (into the camera).

### The lens stack (enforced in `scad/lib/lens/params.scad`)

```
seat_z       = flange_to_rear_vertex               // rear face of the element group, from z=0
group_thk    = element_count·element_edge_thk + (element_count−1)·element_gap
front_elem_z = seat_z + group_thk
retainer_z0  = front_elem_z                         // coarse printed thread clamps the group back
barrel_front_z = retainer_z0 + retainer_engage + front_rim
total_track  = barrel_front_z + thread_engage
```

`assert()`s fail the render if the rear vertex lands inside the male thread, if
`clear_aperture_d` leaves no seat rim, if the barrel wall is too thin around the retainer
thread, or if a chosen `filter_thread` has no wall over the aperture.

`flange_to_rear_vertex` is the lens equivalent of the camera's `board_to_sensor_surface`:
get it from the element prescription, or measure back focus on the bench and adjust. Fine
focus is still the camera's shim stack plus (for a real lens) the focus ring.

### Limitations

- Fixed focus — no printed helicoid yet. A moving `focus_ring` group is a planned follow-up.
- The retainer thread is a coarse (1 mm pitch) printed thread; the optional front
  `filter_thread` is modelled at true 0.5 mm pitch and prints marginally on FDM, same
  caveat as the printed C-mount thread.
- No baffles / internal blackening geometry; paint the bore or add a flock liner.

## Receiver optic (vibrometer)

`mapscam` also prints a **large-aperture receiver telescope** for the M.A.P.S. laser
vibrometer: a bought Ø80 mm f≈150 mm optic, feeding the return beam through an 8 mm
808 nm bandpass filter to a detector on a stock `body`. Two-stage focus — a **coarse
draw-tube** (`barrel` telescopes over `stem`, a wrap `clamp` locks it) plus a **fine
printed helicoid** (`stem` rotates on the `flange` boss). Separate component *type*
(`components/receiver/*.toml`, `scad/lib/receiver/`); it reuses the camera register +
M3 pattern so the flange is a `front_plate` peer. The helicoid uses a light
`linear_extrude(twist=…)` square thread (`helix.scad`), not BOSL2. Full write-up:
[receiver-optic.md](receiver-optic.md).

## Known limitations of v0.1

- Sensor tilt (non-perpendicularity) is controlled only by print flatness of the ledge and
  carrier — no 3-point adjustment yet.
- Tripod boss is on the rear cap edge; not under the centre of mass.
- No gasket groove modelled — sealing is a foam/O-ring pad against flat faces.
- Thermal: no vents or heatsink boss. Fine for low-power global-shutter/rolling sensors
  indoors; revisit for continuous outdoor sun.
