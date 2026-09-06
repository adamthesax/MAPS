#!/usr/bin/env python3
"""capture.py — record the vibrometer analog-front-end output.

Sources:
  --source sound   (default)  sound card / USB audio ADC via `sounddevice`
  --source teensy              binary stream from the sw/firmware DAQ over serial
  --source sim                 synthetic self-mixing signal (no hardware, for tests)

Writes a compressed `.npz` (channel `y`, plus `fs`) and, for the sound path, a
sibling `.wav`. Analyse it with analyze.py / fringe_count.py / homodyne.py.
"""
from __future__ import annotations

import argparse
import sys

import numpy as np

from vibrolib import save_npz, wavelength


def capture_sound(seconds: float, fs: int, channels: int, device):
    import sounddevice as sd

    n = int(seconds * fs)
    print(f"recording {seconds:g} s @ {fs} Hz, {channels} ch ...", file=sys.stderr)
    rec = sd.rec(n, samplerate=fs, channels=channels, dtype="float64", device=device)
    sd.wait()
    return rec[:, 0] if channels == 1 else rec


def capture_teensy(seconds: float, fs: int, port: str, baud: int):
    """Read the firmware's stream: little-endian int16 samples, prefixed sync 0xA5 0x5A."""
    import serial

    n = int(seconds * fs)
    with serial.Serial(port, baud, timeout=2) as s:
        s.reset_input_buffer()
        s.write(b"S")  # ask the firmware to start streaming
        raw = s.read(2 * n + 2)
    buf = np.frombuffer(raw, dtype="<i2")
    # drop a leading partial sync word if present
    y = buf.astype(np.float64)
    y -= np.mean(y)
    y /= 32768.0
    return y[:n]


def capture_sim(seconds: float, fs: int, tone: float, laser: str, v_mean: float = 2e-3,
                mode: str = "smi"):
    if mode == "speckle":
        # Phase-0: intensity roughly linear in displacement -> a tone plus the
        # mild even/odd harmonics a speckle/knife-edge return adds, plus noise.
        t = np.arange(int(seconds * fs)) / fs
        w = 2 * np.pi * tone * t
        y = np.sin(w) + 0.05 * np.sin(2 * w) + 0.02 * np.sin(3 * w)
        y += 0.01 * np.random.default_rng(0).standard_normal(t.size)
        return y

    # Phase-1: synthetic self-mixing signal — a surface approaching at `v_mean`
    # (m/s) while vibrating at `tone` Hz. The net approach keeps the round-trip
    # phase monotonic, so fringe_count.py has a well-posed demod (matches the
    # 'moving surface' check in docs/vibrometer/plan.md).
    t = np.arange(int(seconds * fs)) / fs
    lam = wavelength(laser)
    # keep peak vibration velocity below the drift so the round-trip phase stays
    # monotonic — single-channel SMI can't resolve direction reversals (that needs
    # the Phase-2 quadrature head).
    amp = 0.6 * v_mean / (2 * np.pi * tone)
    disp = v_mean * t + amp * np.sin(2 * np.pi * tone * t)
    phi = 4 * np.pi * disp / lam                    # round-trip phase
    y = np.cos(phi) + 0.08 * np.cos(2 * phi)        # slight SMI asymmetry
    y += 0.005 * np.random.default_rng(0).standard_normal(t.size)
    return y


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-o", "--out", default="capture.npz", help="output .npz path")
    p.add_argument("--source", choices=["sound", "teensy", "sim"], default="sound")
    p.add_argument("--seconds", type=float, default=5.0)
    p.add_argument("--fs", type=int, default=48000, help="sample rate (Hz)")
    p.add_argument("--channels", type=int, default=1, help="sound source: 1 (AC) or 2 (AC+DC / I+Q)")
    p.add_argument("--device", default=None, help="sounddevice device index or name")
    p.add_argument("--port", default=None, help="teensy source: serial port")
    p.add_argument("--baud", type=int, default=2000000)
    p.add_argument("--tone", type=float, default=1000.0, help="sim/reference tone (Hz); stored as metadata")
    p.add_argument("--laser", default="650nm", help="sim source: laser wavelength")
    p.add_argument("--sim-velocity", type=float, default=2e-3,
                   help="sim source: mean approach velocity, m/s (default 2 mm/s)")
    p.add_argument("--sim-mode", choices=["smi", "speckle"], default="smi",
                   help="sim source: Phase-1 self-mixing or Phase-0 speckle tone")
    args = p.parse_args(argv)

    if args.source == "sound":
        y = capture_sound(args.seconds, args.fs, args.channels, args.device)
    elif args.source == "teensy":
        if not args.port:
            p.error("--source teensy needs --port")
        y = capture_teensy(args.seconds, args.fs, args.port, args.baud)
    else:
        y = capture_sim(args.seconds, args.fs, args.tone, args.laser, args.sim_velocity,
                        args.sim_mode)

    y = np.asarray(y, dtype=np.float64)
    if y.ndim == 2:
        save_npz(args.out, args.fs, i=y[:, 0], q=y[:, 1], tone=np.float64(args.tone))
    else:
        save_npz(args.out, args.fs, y=y, tone=np.float64(args.tone))
    print(f"wrote {args.out}  ({y.shape[0]} samples, {y.shape[0]/args.fs:.3f} s)", file=sys.stderr)

    if args.source == "sound" and args.out.endswith(".npz"):
        from scipy.io import wavfile

        wav = args.out[:-4] + ".wav"
        peak = np.max(np.abs(y)) or 1.0
        wavfile.write(wav, args.fs, (y / peak * 0.99 * 32767).astype(np.int16))
        print(f"wrote {wav}", file=sys.stderr)


if __name__ == "__main__":
    main()
