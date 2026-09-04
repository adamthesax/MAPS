# `sw/vibrometer` — acquisition + analysis

Python tools for the M.A.P.S. laser vibrometer, staged to match the hardware
(see [`docs/vibrometer/plan.md`](../../docs/vibrometer/plan.md) and
[`docs/vibrometer/design-notes.md`](../../docs/vibrometer/design-notes.md)).

| Phase | Script | What it does |
|---|---|---|
| 0 — speckle | `capture.py` | Record the AFE AC output from a sound card / audio ADC to `.wav` + `.npz` |
| 0 — speckle | `analyze.py` | Welch PSD, spectrogram, THD against a reference tone — validates the chain |
| 1 — self-mixing | `fringe_count.py` | Band-pass → Hilbert → fringe detection → displacement in λ/2 steps; fringe rate → line-of-sight velocity |
| 2 — homodyne | `homodyne.py` | Read I/Q, Heydemann ellipse-fit calibration, `φ = atan2(Q′, I′)`, unwrap, `x = (λ/4π)·φ` |

All four share [`vibrolib.py`](vibrolib.py) (laser wavelengths, `.npz` I/O, signal
helpers).

## Install

```bash
cd sw/vibrometer
python -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
```

`sounddevice` needs PortAudio (`brew install portaudio` / `apt install libportaudio2`).
Everything except live capture works from a saved `.npz`/`.wav` with no audio backend.

## DAQ options

| Backend | Bandwidth | Use |
|---|---|---|
| PC sound card line-in | ≤ ~20 kHz | Phase 0, and Phase 1 for slow (< a few mm/s) targets |
| USB audio ADC (PCM1808 @ 96 kHz, or a 192 kHz interface) | ≤ ~40–90 kHz | Phase 1 general bench use |
| Teensy 4 / RP2040 streaming its ADC over USB — [`sw/firmware/`](../firmware/) | 200 kHz–1 MHz | Phase 1 Doppler / fast targets, Phase 2 |

`capture.py --source teensy --port /dev/tty.usbmodem*` reads the firmware's binary
stream; `--source sound` (default) uses `sounddevice`.

## No hardware? Use the simulator

`capture.py --source sim` synthesises a capture so the analysis path can be
exercised (and regression-tested) with nothing plugged in:

```bash
python capture.py --source sim --sim-mode speckle --fs 48000 --tone 1000 -o p0.npz
python analyze.py p0.npz --tone 1000            # ~5 % THD, harmonics ~-26 dBc

python capture.py --source sim --sim-mode smi --fs 250000 --tone 800 -o smi.npz
python fringe_count.py smi.npz --laser 650nm --bandpass 200 100000   # mean LOS velocity -> 2.000 mm/s
```

## Typical session

```bash
# Phase 0 — recover a driven speaker tone
python capture.py --seconds 5 --fs 48000 --tone 1000 -o run0.npz
python analyze.py run0.npz --tone 1000

# Phase 1 — displacement + velocity from a self-mixing capture
python capture.py --source teensy --port /dev/tty.usbmodem12341 --seconds 2 --fs 250000 -o smi.npz
python fringe_count.py smi.npz --laser 650nm --bandpass 1e3 80e3

# Phase 2 — calibrated displacement from a quadrature capture
python homodyne.py iq.npz --laser hene --plot
```
