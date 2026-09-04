# `sw/firmware` — streaming DAQ for the vibrometer

A minimal ADC-over-USB bridge for the self-mixing / Doppler case, where the
fringe band runs past what a sound card can sample (100s of kHz). The host side
is `sw/vibrometer/capture.py --source teensy`.

> `mapscam` is "mechanical + docs, no firmware" **for `scad/lib/`**. Instrument
> DAQ firmware lives here under `sw/`, deliberately outside the OpenSCAD tree.

## What it does

- Free-runs the on-chip ADC on one pin (the AFE DC-coupled output) at a fixed
  rate set by `SAMPLE_HZ`.
- On receiving `'S'` on USB serial, streams raw samples as little-endian `int16`,
  preceded once by the sync word `0xA5 0x5A`.
- `'X'` stops. No framing per-sample — the host reads a fixed count.

## Targets

| Board | Sketch | Notes |
|---|---|---|
| Teensy 4.0 / 4.1 | `teensy4_daq/teensy4_daq.ino` | ADC + IntervalTimer, ~1 MHz achievable; USB CDC easily keeps up at 250 kHz |
| RP2040 (Pico) | `rp2040_daq/rp2040_daq.ino` | `analogRead` loop + `tud_cdc` bulk; comfortable to ~200 kHz |

Build with the Arduino IDE / `arduino-cli` and the matching core (Teensyduino or
`arduino-pico`). Set the same `SAMPLE_HZ` here and `--fs` on `capture.py`.

## Wiring

```
AFE DC output ──[ RC anti-alias, fc ≈ SAMPLE_HZ/3 ]──► ADC_PIN (A0)
AFE GND ───────────────────────────────────────────── board GND
```

Keep the ADC reference clean (tie AREF to the AFE analog rail through a ferrite +
100 nF, or use the internal reference and scale in software).
