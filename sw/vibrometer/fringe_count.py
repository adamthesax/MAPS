#!/usr/bin/env python3
"""fringe_count.py — Phase 1 self-mixing displacement + velocity.

Pipeline (see docs/vibrometer/design-notes.md "Self-mixing"):

  1. band-pass the AFE output to the fringe band
  2. Hilbert -> analytic signal -> unwrapped instantaneous phase
  3. displacement  x(t) = (lambda / (4*pi)) * phase        [lambda/2 per fringe]
  4. fringe count  N = phase / (2*pi)
  5. velocity      v(t) = (lambda/2) * f_fringe(t),  f_fringe = (1/2pi) dphase/dt

Direction is ambiguous for plain single-channel SMI; the reconstruction assumes
monotonic phase within each half-cycle. A `--dc` normalisation channel (pick-off
DC) improves the sub-fringe estimate.
"""
from __future__ import annotations

import argparse
import sys

import numpy as np

from vibrolib import analytic_phase, bandpass, load_signal, wavelength


def reconstruct(y, fs, lam, lo, hi):
    yb = bandpass(y, fs, lo, hi)
    yb = yb / (np.std(yb) or 1.0)
    env, phase = analytic_phase(yb)

    x = lam / (4 * np.pi) * phase           # displacement, m
    x -= np.mean(x)
    n_fringes = (phase.max() - phase.min()) / (2 * np.pi)

    dphi = np.gradient(phase, 1.0 / fs)
    f_fringe = dphi / (2 * np.pi)
    v = lam / 2.0 * f_fringe                # line-of-sight velocity, m/s
    return yb, env, x, v, n_fringes


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("capture", help=".npz / .wav from capture.py")
    p.add_argument("--channel", default=None)
    p.add_argument("--laser", default="650nm", help="wavelength name or nm value")
    p.add_argument("--bandpass", nargs=2, type=float, metavar=("LO", "HI"), default=[500.0, 40000.0])
    p.add_argument("--plot", action="store_true")
    p.add_argument("--save", default=None)
    args = p.parse_args(argv)

    fs, y = load_signal(args.capture, args.channel)
    lam = wavelength(args.laser)
    lo, hi = args.bandpass

    yb, env, x, v, n = reconstruct(y, fs, lam, lo, hi)
    t = np.arange(x.size) / fs

    # split net drift (mean Doppler) from the vibration riding on it
    coef = np.polyfit(t, x, 1)
    x_vib = x - np.polyval(coef, t)
    v_mean = coef[0]

    print(f"laser             : {args.laser}  (lambda = {lam*1e9:.2f} nm, lambda/2 = {lam/2*1e9:.2f} nm)")
    print(f"record            : {t[-1]:.4f} s @ {fs:g} Hz")
    print(f"fringes (total)    : {n:.1f}")
    print(f"mean LOS velocity  : {v_mean*1e3:.4f} mm/s   (from the net fringe rate)")
    print(f"vibration p-p      : {(x_vib.max()-x_vib.min())*1e9:.1f} nm")
    print(f"vibration rms      : {np.std(x_vib)*1e9:.1f} nm")
    print(f"velocity rms       : {np.std(v)*1e3:.3f} mm/s   (peak {np.max(np.abs(v))*1e3:.3f} mm/s)")

    if args.plot or args.save:
        import matplotlib.pyplot as plt

        fig, ax = plt.subplots(3, 1, figsize=(9, 8), sharex=True)
        ax[0].plot(t, yb, lw=0.6)
        ax[0].set(ylabel="AFE (norm)", title=f"self-mixing — {args.capture}")
        ax[1].plot(t, x * 1e9, lw=0.8)
        ax[1].set(ylabel="displacement (nm)")
        ax[2].plot(t, v * 1e3, lw=0.8)
        ax[2].set(ylabel="velocity (mm/s)", xlabel="s")
        for a in ax:
            a.grid(True, alpha=0.3)
        fig.tight_layout()
        if args.save:
            fig.savefig(args.save, dpi=120)
            print(f"wrote {args.save}", file=sys.stderr)
        else:
            plt.show()


if __name__ == "__main__":
    main()
