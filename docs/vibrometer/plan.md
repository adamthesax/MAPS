# Plan: BPW34-based laser vibrometer for M.A.P.S.

## Context

M.A.P.S. (Modular Awesome Photonic System) currently has one repo, `mapscam`: a
parametric OpenSCAD enclosure for board-level C-mount CMOS cameras. The user wants a
second instrument in the same family — a **laser vibrometer** built around the
**BPW34** silicon PIN photodiode as the detector — that reuses the mapscam module
interface so it drops onto the same printed-camera ecosystem.

Requirements gathered from the user:

- **Compare the sensing principles in the plan** (done below; no pre-commit).
- **Staged**: a qualitative bench instrument first, with a clear upgrade path to
  calibrated (wavelength-traceable) displacement/velocity.
- **General bench experimentation** is the target use — not one fixed application.
- **Tie into M.A.P.S. / this repo**: the optical head is a printed module on the
  shared mapscam interface.

**Decisions locked (from the clarifying questions):**

1. Lives **inside `mapscam`** — new `scad/lib/` module + variant, plus new `elec/`
   and `sw/` top-level trees.
2. Head form: **standalone interface stack** — a `front_plate`-style module
   (`reg_boss()` + `corner_ears()` + `mate_screws`) that bolts to a stock mapscam
   `body`; the `body` carries the analog-front-end PCB instead of a sensor carrier.
   (C-mount screw-on barrel noted as an optional alternative, not built now.)
3. Phase-1 self-mixing laser: **650 nm, visible.**
4. Depth this pass: **Phases 0 + 1 fully build-ready; Phase 2 (Michelson) sketched.**

Intended outcome: a documented, buildable instrument — printed optical head +
BPW34 analog front-end + laser driver + acquisition/analysis software — that starts
returning vibration spectra in a weekend and can grow into a quadrature homodyne
interferometer.

### Invariant handling (`CLAUDE.md`)

`mapscam` is "mechanical design + docs only, no firmware", and `params.scad`
asserts a valid **camera** flange-focal-distance stack. The vibrometer has no
sensor PCB / FFD, but the standalone-stack head reuses the stock `body`, whose
length is derived from that stack.

**Resolution — no `params.scad` edits, asserts stay meaningful:**

- The `vibrometer_smi_650` variant **pins a nominal, self-consistent sensor stack**
  (dummy `board_to_sensor_surface`, `standoff_h`, etc.) that passes all three
  `assert()`s. `body_length` then *solves* exactly as for a camera, and its echoed
  value is simply the internal cavity budget the AFE PCB must fit. Invariant #1
  ("`body_length` is derived, never set") and #2 (asserts meaningful) are both
  respected — the vibrometer just feeds the same solver a valid stack.
- The head is a `front_plate` peer: it honours `scad/lib/interface.scad` exactly
  (`corner_ears`, `mate_screw_xy`, `reg_boss`, +X index key, absolute Z with
  `z = 0` at the mate/flange face), per invariant #3.
- The `sensor_carrier` is swapped for an `afe_carrier` that mounts the AFE PCB on
  the same body ledge + shim datum.
- Firmware / DAQ code lives in a **new top-level `sw/`** (incl. `sw/firmware/` for a
  Teensy/RP2040 DAQ sketch); electronics in a **new top-level `elec/`** (KiCad).
  `scad/lib/` stays pure OpenSCAD — the "no firmware" rule is scoped there.
- `CLAUDE.md` + `README.md` get a short note that the repo now also hosts the
  vibrometer head, `elec/`, and `sw/`.

---

## Sensing principle comparison

| | **A. Speckle / intensity deflection** | **B. Self-mixing interferometry (SMI)** | **C. Michelson homodyne (quadrature)** |
|---|---|---|---|
| How | Laser spot on a diffuse surface; BPW34 reads speckle boil or a knife-edge-clipped return | Light reflected off the target re-enters the laser cavity and modulates its output power; BPW34 reads that power (rear-facet or pick-off) | Beam split to a reference mirror + the target; BPW34(s) read the recombined fringe |
| Optics needed | laser + 1 diode. No alignment | laser + collimator + 1–2 diodes + a glass pick-off | 50:50 beamsplitter, reference mirror on a PZT, λ/4 plate + polarizers, 2–3 diodes, rigid breadboard |
| Output | **relative** vibration spectrum / recovered audio | fringes: **λ/2 per fringe** displacement; velocity from fringe rate. Direction ambiguous without extra tricks | **absolute** displacement, `x = (λ/4π)·φ`, direction-sensitive; velocity = dx/dt |
| Quantitative? | no | semi (counts, ~λ/2 ≈ 325 nm steps; sub-fringe with modeling) | yes, sub-nm in-band with good SNR |
| Coherence demand | none | target within laser coherence length (cm for a single-mode diode) | path lengths matched to coherence length; wants a HeNe or temp-stabilized SM diode |
| Fits a compact single-axis printed head? | trivially | **yes** — single axis, no reference arm | no — needs a bench layout |
| Cost | ~$15 | ~$40–70 | ~$150–300 (HeNe, cube BS, PZT, waveplate) |
| Main risk | non-quantitative, speckle dropouts | feedback level tuning; getting a clean signal onto BPW34 | alignment + mechanical stability; fringe locking |

### Recommended ladder (matches "both, staged")

1. **Phase 0 — Speckle (Principle A).** Proves the BPW34 front-end, the laser
   driver, and the whole DAQ/analysis chain against a known source (drive a speaker
   with a tone generator, recover the tone and its harmonics). ~1 weekend.
2. **Phase 1 — Self-mixing (Principle B).** The "awesome photonic" core: the
   printed interface-stack head = collimated 650 nm laser diode + BPW34 pick-off,
   bolted to a stock mapscam `body` that carries the AFE PCB. Gives real
   displacement in λ/2 units and velocity from Doppler fringe rate. Primary
   deliverable.
3. **Phase 2 — Michelson homodyne quadrature (Principle C).** Separate bench build
   sharing the same front-end board and software. Delivers calibrated, direction-
   sensitive sub-nm displacement. Optional / later.

Heterodyne (AOM/Bragg-cell) velocimetry is explicitly **out of scope** — cost and
RF complexity outweigh the benefit for a bench instrument.

---

## Subsystem designs

### 1. BPW34 analog front-end (`elec/afe/`) — shared by all phases

- **Bias:** photoconductive mode, VR ≈ 9–12 V (from a small boost or a 9 V battery /
  12 V bench rail). Drops junction capacitance from ~70 pF (0 V) to ~12–15 pF →
  needed for bandwidth and linearity.
- **Transimpedance amp:** op-amp TIA, `Rf` switch-selectable 100 kΩ / 1 MΩ /
  10 MΩ; feedback cap `Cf` sized per range for phase margin
  (`f_p = 1/(2πRf·Cf)`, target ~200–500 kHz on the 1 MΩ range).
  - Phase-0 op-amp: jellybean FET-input (OPA2340 / MCP662 / TLV2462) — fine to
    20 kHz.
  - Phase-1/2 op-amp: **OPA657** or OPA847 (low input capacitance, high GBW) for
    clean fringe signals into the 100s of kHz (Doppler beat of a few mm/s target).
  - Footprint the board for both (SOT-23-5 + SOIC-8 pads, or a socketed daughter).
- **Second stage:** ×10–×100 switchable gain + a 4th-order anti-alias low-pass
  (Sallen-Key, corner selectable 20 kHz / 100 kHz / 500 kHz).
- **Outputs:** (a) **DC-coupled** buffered output for fringe counting / phase
  demod; (b) **AC-coupled** (high-pass ~2 Hz) output scaled to ±1 V for a sound
  card / audio ADC.
- **Noise budget (sanity):** 1 MΩ Rf Johnson noise ≈ 0.13 pA/√Hz (≈ 18 pA rms over
  20 kHz); shot noise on ~4 µA photocurrent ≈ 1.1 pA/√Hz. Resistor-limited at low
  light, shot-limited with a good return — acceptable. At an interferometric mid-
  fringe this maps to roughly sub-nm displacement resolution in a 20 kHz band with
  a decent return beam.
- **Power:** ±5 V (or single 5 V + bias ref) LDO from USB or a bench supply;
  separate quiet rail for the TIA.
- **Deliverable:** KiCad schematic + 2-layer board, or for Phase 0 a documented
  perfboard build in `elec/afe/README.md`.

### 2. Laser + driver (`elec/laser/`)

- **Phase 0:** any 650 nm 1–5 mW diode module with its own driver (or an LM317
  constant-current source, ~30–50 mA). Cheap, disposable.
- **Phase 1 (SMI):** a **single-mode 650 nm laser diode** (visible for alignment;
  responsivity ~0.4 A/W on BPW34) in a collimating housing — a real single-mode
  diode, not a pointer module, so the coherence length covers a bench standoff.
  Driver: low-noise constant current (dedicated IC e.g. iC-Haus iC-WKN, or a clean
  discrete mirror) + optional bias-T to also read the junction-voltage SMI signal
  as a cross-check against the BPW34 channel.
- **Phase 2 (Michelson):** used **HeNe tube + brick supply** (632.8 nm, coherence
  length ~0.2 m+, excellent amplitude/frequency stability) is the low-risk choice;
  alternative is a temperature-controlled single-mode diode (TEC + thermistor loop
  on the same board).
- Interlock / current-limit / slow-start on every driver. Class 3R handling notes
  in the docs.

### 3. Optical head — printed interface-stack module (`scad/`)

**Stack:** `vibrometer_head` → stock `body` → stock `rear` (gland for the cable);
`afe_carrier` on the body ledge in place of `sensor_carrier`. Any mapscam `body` /
`rear` / `base` variant is reusable unchanged.

**`scad/lib/vibrometer_head.scad`** — a `front_plate` peer:

- Presents `reg_boss()` + `corner_ears(h)` + `mate_screws("clear", h)` from
  `scad/lib/interface.scad`; keeps the +X index key; authored in absolute Z with
  the mate face at `z = 0`, optics projecting to `−Z` (out the front).
- Phase-1 SMI internals, all at `z ≤ 0`:
  - TO-can laser-diode pocket (press-fit + M2 grub screw) on-axis at the rear,
  - seat for an aspheric collimating lens,
  - a thin glass pick-off (microscope coverslip) at ~45° sending a few % sideways
    to a **BPW34 pocket** in the wall,
  - clear exit aperture with an optional protective-window ledge,
  - a cable channel from the laser/BPW34 pockets through the register into the body.
- Parametric knobs in a **new `scad/lib/vib_params.scad`** (isolated from
  `params.scad`): `laser_can_d`, `collimator_focal`, `pickoff_angle`,
  `bpw34_pkg` (2.7 mm bare / 5.4 mm leaded), `exit_aperture_d`, `head_len`.
- Reuse: `rprism` + helpers (`scad/lib/util.scad`); `screw_clear` / `heatset`
  (`scad/lib/hardware.scad`); the interface module (`scad/lib/interface.scad`).

**`scad/lib/afe_carrier.scad`** — clone of `sensor_carrier` geometry: same body-ledge
register + shim datum + `mate_screw_xy()` bolt pattern, but the pocket and standoffs
are sized to the AFE PCB outline (define `afe_pcb_x/y/thickness` in `vib_params.scad`)
with a connector cutout toward the rear gland.

**`scad/variants/vibrometer_smi_650.scad`** — `include <../lib/params.scad>` → pin a
nominal passing sensor stack + `include <vib_params.scad>` overrides →
`include <../lib/dispatch.scad>`, mirroring the camera variant pattern
(`docs/modularity.md` "override mechanics").

**Phase-2 sketch only** — `scad/lib/vib_optics_mounts.scad`: printed BS-cube holder,
PZT-mirror cell, quadrature detector cluster (λ/4 + 2 polarizer slots + 2–3 BPW34s)
on a 25 mm breadboard grid. Interface note + rough geometry this pass; detailed
model deferred.

### 4. Acquisition + analysis software (`sw/vibrometer/`)

Python, staged to match the hardware:

- **Phase 0:** `capture.py` — `sounddevice` line-in capture; `analyze.py` — Welch
  PSD, spectrogram, THD vs a reference tone. Validates the chain.
- **Phase 1 (SMI):**
  - `fringe_count.py` — band-pass, Hilbert envelope, zero-cross / peak detection →
    displacement in λ/2 steps; fringe-rate → line-of-sight velocity
    (`v = (λ/2)·f_fringe`).
  - sub-fringe estimation via the SMI phase model (arcsin on the normalized
    signal, with the pick-off DC channel for normalization).
- **Phase 2 (homodyne):** `homodyne.py` — read I/Q channels, ellipse-fit
  calibration (Heydemann correction) for gain/offset/quadrature error,
  `φ = atan2(Q', I')`, unwrap, `x = (λ/4π)·φ`; velocity and acceleration by
  differentiation; live scope + PSD GUI (matplotlib or a small PyQtGraph app).
- **DAQ options**, documented in `sw/vibrometer/README.md`: PC sound card (≤20 kHz,
  Phase 0/1 low-speed), USB audio ADC like PCM1808 @ 96 kHz, or a Teensy 4
  / RP2040 streaming its ADC over USB for the 100s-of-kHz SMI/Doppler case. A tiny
  `firmware/` sketch for the Teensy path lives under `sw/`, not in `scad/`.

---

## Bill of materials (headline, per phase)

- **Phase 0 (~$15–25):** BPW34 ×2, op-amp, resistors/caps, 9 V battery + clip,
  650 nm laser module, perfboard.
- **Phase 1 (~$40–70):** + single-mode 650 nm diode + collimator lens, low-noise
  current driver parts, coverslip pick-off, printed `vib_head` + stock mapscam
  `body`/`rear`/gland, small AFE PCB, optional USB audio ADC.
- **Phase 2 (~$150–300):** + HeNe tube & supply (or TEC-stabilized diode), 50:50
  beamsplitter cube, PZT + reference mirror, λ/4 waveplate + 2 polarizers,
  aluminium breadboard, extra BPW34s, Teensy DAQ.

Full itemized BOM with part numbers goes in `docs/vibrometer/bom.md`.

---

## Files to add / modify

**New docs**
- `docs/vibrometer/design-notes.md` — principle comparison, the interferometer
  math, the phased roadmap, laser-safety notes.
- `docs/vibrometer/electronics.md` — AFE + driver design, values, noise budget.
- `docs/vibrometer/bom.md`, `docs/vibrometer/assembly.md`,
  `docs/vibrometer/calibration.md` (ellipse fit, tone-source check).

**New SCAD**
- `scad/lib/vib_params.scad` — vibrometer knobs (isolated from `params.scad`).
- `scad/lib/vibrometer_head.scad` — the interface-stack SMI head (`front_plate` peer).
- `scad/lib/afe_carrier.scad` — AFE-PCB carrier (clone of `sensor_carrier`).
- `scad/lib/vib_optics_mounts.scad` — Phase-2 bench mounts (sketch geometry only).
- `scad/variants/vibrometer_smi_650.scad` — pin a nominal passing stack +
  `vib_params` overrides → `include dispatch`.
- Edit `scad/lib/dispatch.scad` — add `part == "vib_head"` and `part == "afe"`
  branches; add the vibrometer stack to the exploded `assembly` preview, guarded so
  camera variants render identically to today.

**Build / metadata**
- `Makefile` — new `VIB_VARIANTS` + `VIB_PARTS := vib_head body afe rear` (parts
  list differs from camera `PARTS`), wired into `all`, per-variant rules, and
  `check`.
- `variants.json` — add the entry (note the different part set).
- `.github/workflows/render.yml` — include the new variant in CI.

**New trees**
- `elec/afe/`, `elec/laser/` — KiCad projects + READMEs.
- `sw/vibrometer/` — Python package + `README.md`; `sw/firmware/` for the Teensy
  DAQ sketch.

**Touch**
- `CLAUDE.md` — one paragraph: repo now also carries the vibrometer head + `elec/`
  + `sw/`; the "no firmware" rule still applies to `scad/lib/`.
- `README.md` — new section + variant-table row.
- `docs/modularity.md` — list `vibrometer_head` + `afe_carrier` in the module list
  as a `front_plate` / `sensor_carrier` peer pair.
- `.claude/skills/` — optional new skill `add-vibrometer-head` later; not in this
  pass.

---

## Verification

**SCAD / repo (CI-gate parity)**
- `make check` stays green — camera variants render byte-for-byte as before; the
  vibrometer variant feeds `params.scad` a valid stack so its three `assert()`s
  pass and `body_length` echoes a sane cavity number.
- `OPENSCADPATH=vendor openscad -o stl/vib_head.stl -D 'part="vib_head"'
  scad/variants/vibrometer_smi_650.scad` and `-D 'part="afe"'` each render
  **2-manifold**; inspect the PNGs for the laser pocket, collimator seat, pick-off
  slot, BPW34 pocket, exit bore, and the AFE-PCB pocket + connector cutout.
- Fit test: bolt the printed `vib_head` to a stock `generic_29mm_c` `body` — check
  the register engages, the +X key indexes, and the 4 M3s land in the body inserts.

**Electronics**
- AFE bench check: dark output = offset only; shine a modulated LED (function
  generator → LED) at the BPW34, confirm flat transimpedance response to the
  selected corner and expected gain per `Rf` setting; measure output noise floor
  vs the budget above.
- Laser driver: current setpoint stable, slow-start works, no overshoot on power-up
  (scope the monitor).

**End-to-end, per phase**
- **Phase 0:** drive a speaker with a 1 kHz tone at known SPL; `analyze.py` recovers
  1 kHz + harmonics; sweep 100 Hz–15 kHz and plot the instrument response.
- **Phase 1:** mount a piezo buzzer or a speaker cone on the bench; command known
  displacement amplitudes; confirm fringe count scales as expected
  (N fringes ≈ 2·amplitude / λ); measure a moving surface and check the Doppler
  fringe-rate → velocity against a tachometer / known speed.
- **Phase 2 (sketch validation only):** confirm the bench-mount geometry clears a
  50:800 mm layout on a 25 mm grid; full end-to-end calibration deferred to the
  Phase-2 build.

---

## Sequencing

1. `sw/` Phase-0 capture + analysis (works with a borrowed photodiode/mic — unblocks
   everything).
2. `elec/afe/` front-end (perfboard first, KiCad board in parallel).
3. `elec/laser/` 650 nm driver.
4. Phase-0 speckle end-to-end check → freeze the AFE.
5. `scad/` `vib_params` + `vibrometer_head` + `afe_carrier` + variant; `make check`.
6. Print, populate, assemble; Phase-1 SMI bring-up + `sw/` fringe/velocity code.
7. Docs (`docs/vibrometer/*`), `README.md` / `CLAUDE.md` / `modularity.md` notes.
8. Phase-2 Michelson: flesh out `vib_optics_mounts.scad` + `homodyne.py`.
