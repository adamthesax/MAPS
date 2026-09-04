#!/usr/bin/env python3
"""homodyne.py — Phase 2 quadrature (Michelson homodyne) displacement.

Reads two channels I(t), Q(t) from a quadrature detector, corrects gain / offset
/ non-orthogonality by fitting the Lissajous ellipse (Heydemann correction), then

    phi   = atan2(Q', I')                 (unwrapped)
    x(t)  = (lambda / (4*pi)) * phi       absolute, direction-sensitive
    v(t)  = dx/dt,   a(t) = dv/dt

This is a SKETCH-level implementation to accompany the Phase-2 plan; it runs on
simulated I/Q from capture.py (2-channel) and on real captures once the quadrature
head exists.
"""
from __future__ import annotations

import argparse
import sys

import numpy as np

from vibrolib import load_npz, wavelength


def fit_ellipse(x, y):
    """Least-squares conic fit a x^2 + b xy + c y^2 + d x + e y + f = 0."""
    D = np.column_stack([x * x, x * y, y * y, x, y, np.ones_like(x)])
    _, _, V = np.linalg.svd(D, full_matrices=False)
    return V[-1]


def heydemann(I, Q):
    """Return corrected (I', Q') on the unit circle from raw quadrature signals."""
    a, b, c, d, e, f = fit_ellipse(I, Q)
    # centre
    denom = b * b - 4 * a * c
    x0 = (2 * c * d - b * e) / denom
    y0 = (2 * a * e - b * d) / denom
    Ic, Qc = I - x0, Q - y0
    # de-rotate + rescale axes
    theta = 0.5 * np.arctan2(b, a - c)
    ct, st = np.cos(theta), np.sin(theta)
    u = ct * Ic + st * Qc
    v = -st * Ic + ct * Qc
    su = np.std(u) or 1.0
    sv = np.std(v) or 1.0
    return u / su, v / sv


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("capture", help="2-channel .npz with channels i and q")
    p.add_argument("--laser", default="hene")
    p.add_argument("--plot", action="store_true")
    p.add_argument("--save", default=None)
    args = p.parse_args(argv)

    fs, ch = load_npz(args.capture)
    if not {"i", "q"} <= set(ch):
        p.error(f"{args.capture} has channels {list(ch)}; need 'i' and 'q'")
    lam = wavelength(args.laser)

    Ip, Qp = heydemann(np.asarray(ch["i"], float), np.asarray(ch["q"], float))
    phi = np.unwrap(np.arctan2(Qp, Ip))
    x = lam / (4 * np.pi) * phi
    x -= x[0]
    t = np.arange(x.size) / fs
    v = np.gradient(x, 1.0 / fs)
    a = np.gradient(v, 1.0 / fs)

    print(f"laser           : {args.laser}  (lambda = {lam*1e9:.3f} nm)")
    print(f"record          : {t[-1]:.4f} s @ {fs:g} Hz")
    print(f"displacement p-p : {(x.max()-x.min())*1e9:.2f} nm")
    print(f"displacement rms : {np.std(x)*1e9:.3f} nm")
    print(f"velocity rms     : {np.std(v)*1e3:.4f} mm/s")
    print(f"accel rms        : {np.std(a):.3f} m/s^2")

    if args.plot or args.save:
        import matplotlib.pyplot as plt

        fig, ax = plt.subplots(2, 2, figsize=(11, 7))
        ax[0, 0].plot(ch["i"], ch["q"], ".", ms=1, alpha=0.3, label="raw")
        ax[0, 0].plot(Ip, Qp, ".", ms=1, alpha=0.5, label="corrected")
        ax[0, 0].set(title="Lissajous", aspect="equal")
        ax[0, 0].legend()
        ax[0, 1].plot(t, x * 1e9)
        ax[0, 1].set(title="displacement (nm)", xlabel="s")
        ax[1, 0].plot(t, v * 1e3)
        ax[1, 0].set(title="velocity (mm/s)", xlabel="s")
        ax[1, 1].psd(x, NFFT=min(8192, x.size), Fs=fs)
        ax[1, 1].set(title="displacement PSD")
        for row in ax:
            for a_ in row:
                a_.grid(True, alpha=0.3)
        fig.tight_layout()
        if args.save:
            fig.savefig(args.save, dpi=120)
            print(f"wrote {args.save}", file=sys.stderr)
        else:
            plt.show()


if __name__ == "__main__":
    main()
