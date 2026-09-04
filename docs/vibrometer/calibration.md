# Vibrometer — calibration & bring-up checks

Ordered so each step only depends on the ones before it.

## 1. AFE bench check (no laser)

| Test | Method | Pass |
|---|---|---|
| Offset / dark | Cover the BPW34. Measure `OUT_DC`. | Sits at `VREF` ± a few mV, no oscillation |
| Transimpedance flatness | Function generator → LED aimed at the BPW34, sweep 10 Hz–(corner). | `OUT` flat to the selected AA corner, then rolls off |
| Gain per `Rf` | Known LED photocurrent (measure DC first), step `Rf`. | `OUT/Ipd` ratio matches 100 k / 1 M / 10 M within tolerance |
| Noise floor | FFT `OUT` in the dark, refer to input. | Within ~2× of the budget in [electronics.md](electronics.md#noise-budget) |

`sw/vibrometer/analyze.py <capture> --plot` gives the PSD for the noise-floor step.

## 2. Laser driver check

- Current setpoint stable to < 1 % over 10 min (measure across a 1 Ω sense).
- Soft-start: no overshoot on power-up (scope the sense or monitor PD).
- Interlock opens the current path.

## 3. Phase 0 — end-to-end chain (speckle)

1. Laser spot on a **speaker cone**; drive the speaker with a 1 kHz tone at a
   known SPL.
2. `capture.py --source sound --seconds 5 --fs 48000 --tone 1000 -o p0.npz`
3. `analyze.py p0.npz --tone 1000` → recovers 1 kHz + harmonics; note THD.
4. Sweep 100 Hz–15 kHz; plot `OUT` amplitude vs frequency = the instrument
   response. Flat-ish region = usable band.

Simulator dry-run (no hardware):
`capture.py --source sim --sim-mode speckle --tone 1000 -o p0.npz && analyze.py p0.npz --tone 1000`
→ THD ≈ 5 %.

## 4. Phase 1 — self-mixing displacement

1. Mount a **piezo buzzer** or a speaker cone on the bench; command known
   displacement amplitudes (piezo: from its datasheet nm/V; speaker: cross-check
   with a dial indicator at large amplitude).
2. `capture.py --source teensy --port ... --seconds 2 --fs 250000 -o smi.npz`
3. `fringe_count.py smi.npz --laser 650nm --bandpass 1e3 80e3`
4. Check the fringe count scales as **N ≈ 2·amplitude / λ** (round trip). At
   650 nm, a 1 µm p-p motion ≈ 3 fringes p-p.
5. **Velocity check:** aim at a slowly rotating disc / translating stage at a
   known surface speed; the reported *mean LOS velocity* should match
   `v = (λ/2)·f_fringe` to a few %.

Simulator dry-run:
`capture.py --source sim --sim-mode smi --tone 800 --fs 250000 -o smi.npz && fringe_count.py smi.npz --laser 650nm --bandpass 200 100000`
→ *mean LOS velocity* → 2.000 mm/s, fringe count 6153.8.

### Known limits (Phase 1)

- **Direction ambiguity** at motion reversals — single-channel SMI. Reliable only
  when a net drift dominates, or for spectra (magnitude) rather than signed
  displacement. Phase 2 fixes this.
- Speckle dropouts on rough targets — average, or retro-tape the target.
- Feedback level must be tuned (target distance / return strength) for a clean
  `cos φ` shape; too much feedback → hysteretic sawtooth.

## 5. Phase 2 — homodyne (sketch validation only this pass)

- Confirm the bench-mount geometry (`scad/lib/vibrometer/vib_optics_mounts.scad`) clears a
  ~50–800 mm layout on a 25 mm grid.
- `homodyne.py` runs its Heydemann ellipse fit + displacement reconstruction on
  2-channel captures; `test_pipeline.py` checks it to < 5 % on a synthetic
  multi-fringe I/Q. Full end-to-end calibration is deferred to the Phase-2 build.
