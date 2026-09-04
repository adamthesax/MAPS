# Vibrometer — design notes

The second M.A.P.S. instrument: a **laser vibrometer** built around the **BPW34**
silicon PIN photodiode. It is **the same enclosure as a camera** — only the
"sensor board" changes. See [`plan.md`](plan.md) for the full roadmap and the
decisions behind it.

```
  target ◄── beam ── [ front ] ── [ body ] ── [ carrier ] ── [ rear ] ── cable
                         (bore)        │
                                 [ laser_board ]   collimated 650 nm laser +
                                                   BPW34 pick-off, on the carrier
                                                   standoffs where a CMOS PCB goes
```

`front` / `body` / `carrier` / `rear` / `base` / `shims` are the **stock camera
parts, unchanged**. `scad/lib/vibrometer/params.scad` `include`s
`scad/lib/camera/params.scad` and pins the camera-default stack, so `body_length`
derives to the identical **26.626 mm** (`generic_29mm_c`). The only new part is
**`laser_board`** — a printed sub-mount that bolts to the carrier standoffs at
the same `board_hole_pitch` M2 pattern, back face at `pcb_back_z`, exactly like a
sensor PCB. It carries a forward barrel (TO-can laser + collimator + 45° glass
pick-off + BPW34 pocket) that reaches through the front-plate bore and a few mm
past the flange. The front plate defaults to `mount_type = "blank"` (plain exit
bore, no thread tower); set `"C"` to add a thread for a screw-on window or
filter. See [modularity.md](../modularity.md).

## Sensing principle

| | A. Speckle / intensity | B. Self-mixing (SMI) | C. Michelson homodyne |
|---|---|---|---|
| Optics | laser + 1 diode, no alignment | laser + collimator + 1–2 diodes + glass pick-off | 50:50 BS, ref mirror on PZT, λ/4 + polarizers, 2–3 diodes, breadboard |
| Output | **relative** vibration spectrum | fringes: **λ/2 per fringe**; velocity from fringe rate | **absolute** `x = (λ/4π)·φ`, direction-sensitive |
| Quantitative | no | semi (≈ λ/2 ≈ 325 nm steps; sub-fringe with a model) | yes, sub-nm in-band |
| Coherence | none | target within the laser coherence length | paths matched; wants HeNe or a temp-stabilised SM diode |
| Compact printed head | trivially | **yes** — single axis, no reference arm | no — needs a bench |
| Cost | ~$15 | ~$40–70 | ~$150–300 |

**Ladder we build:** Phase 0 speckle (proves the chain) → **Phase 1 self-mixing
(primary deliverable)** → Phase 2 Michelson homodyne (sketched only this pass).
Heterodyne (AOM/Bragg-cell) velocimetry is explicitly out of scope.

## The interferometer math

### Self-mixing (Phase 1)

Light back-scattered from the target re-enters the laser cavity and modulates its
output power. In the weak-feedback regime the BPW34 sees

```
  P(t) = P0 · [ 1 + m · cos( φ(t) ) ] ,     φ(t) = (4π / λ) · d(t)
```

where `d(t)` is the target displacement along the beam (the `4π` is the round
trip). Consequences:

- **One fringe = λ/2 of displacement.** At 650 nm, λ/2 = **325 nm**.
- **Line-of-sight velocity** from the instantaneous fringe rate:
  `v = (λ/2) · f_fringe`. A target at 1 mm/s gives `f_fringe ≈ 3.1 kHz`.
- **Direction** is ambiguous for a single detector channel — the cosine folds at
  turning points. `sw/vibrometer/fringe_count.py` assumes the phase is monotonic
  within a half-cycle (true when a net drift dominates the vibration); full
  direction sensitivity needs the Phase-2 quadrature head. The slight asymmetry
  of the real SMI waveform (feedback parameter `C`) carries direction information
  that a model can exploit, but that is not implemented yet.
- **Coherence:** a real single-mode diode (not a pointer module) keeps the
  coherence length well beyond a bench standoff.

### Michelson homodyne quadrature (Phase 2)

Split to a reference mirror and the target; recombine; read two detectors in
quadrature (λ/4 plate + crossed polarizers, or a 3×120° cluster). After Heydemann
ellipse-fit correction of gain / offset / non-orthogonality:

```
  φ = atan2(Q', I') ,   unwrap ,   x = (λ / 4π) · φ
```

Absolute, direction-sensitive, sub-nm in-band with good SNR. Velocity and
acceleration by differentiation. Needs path lengths matched to the coherence
length — a HeNe (coherence ~0.2 m+) is the low-risk source.

## Laser safety

650 nm at 1–10 mW is **Class 3R** (bench builds may reach 3B). House rules:

- Interlock + hard current limit + soft-start on every driver (`elec/laser/`).
- Never look into the beam or specular reflections; beam path at not-eye height;
  beam blocks / dumps at the ends.
- No watches / rings / shiny tools in the beam plane.
- A visible-wavelength diode is the *safer* choice — the blink reflex works.
- Label the instrument. Keep the beam enclosed once aligned (the barrel exit
  aperture + an optional screw-on window with `mount_type = "C"` help).

## Why it stays inside `mapscam` and keeps the invariants

`CLAUDE.md` scopes "mechanical + docs, no firmware" to `scad/lib/` and asserts a
valid **camera** flange-focal-distance stack in `scad/lib/camera/params.scad`.
The vibrometer has no CMOS sensor, but it runs the **same body**, whose length is
*solved* from that stack.

- The vibrometer is its **own component type** — `components/_type/vibrometer.toml`,
  alongside `camera` and `lens` (see [../components.md](../components.md)) — but
  its `parts` list is the camera's six parts with the CMOS PCB replaced by
  `laser_board`.
- `scad/lib/vibrometer/params.scad` **`include`s `scad/lib/camera/params.scad`**
  and pins the camera-default stack (`board_to_sensor_surface = 2.5`,
  `standoff_h = 4.0`, `mount_type = "blank"`). All three camera `assert()`s stay
  meaningful, and `body_length` still *derives* — to **26.626 mm, byte-identical
  to `generic_29mm_c`**. **No `scad/lib/camera/params.scad` edits.**
- `scad/lib/vibrometer/dispatch.scad` `use`s the stock camera modules
  (`use <../camera/front_plate.scad>` …) and adds only `laser_board`. The camera
  dispatch is untouched. `laser_board` extra asserts (barrel clears the bore, the
  can + collimator fit, the pick-off lands on exposed barrel) sit alongside the
  camera's.
- `components/vibrometer/vibrometer_smi_650.toml` pins the few `laser_board`
  parameters that differ from the type defaults; `make gen` expands it.
- DAQ / firmware code lives in a top-level `sw/` (incl. `sw/firmware/`);
  electronics in a top-level `elec/` (the transimpedance front end is a small PCB
  wired to the laser board — carrier back or external, not a printed part).
  `scad/lib/` stays pure OpenSCAD.
