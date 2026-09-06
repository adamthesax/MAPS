#!/usr/bin/env python3
"""analyze.py — Phase 0 chain validation.

Welch PSD + spectrogram of a capture, and (with --tone) the total harmonic
distortion and instrument response at a driven reference frequency. Proves the
BPW34 front end + laser driver + DAQ recover a known vibration.
"""
from __future__ import annotations

import argparse
import sys

import numpy as np

from vibrolib import detrend_ac, load_signal


def thd(x: np.ndarray, fs: float, f0: float, n_harm: int = 6):
    """Return (thd_ratio, {harmonic: amplitude}) by summing bin power near k*f0."""
    from scipy.signal import periodogram

    f, pxx = periodogram(x, fs=fs, window="hann", scaling="spectrum")
    df = f[1] - f[0]
    bw = max(3 * df, f0 * 0.02)

    def band_amp(fc):
        m = (f >= fc - bw) & (f <= fc + bw)
        return np.sqrt(np.sum(pxx[m])) if np.any(m) else 0.0

    amps = {k: band_amp(k * f0) for k in range(1, n_harm + 1)}
    fund = amps[1]
    harm = np.sqrt(sum(a * a for k, a in amps.items() if k >= 2))
    return (harm / fund if fund else np.nan), amps


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("capture", help=".npz or .wav from capture.py")
    p.add_argument("--channel", default=None, help="channel name for multi-channel .npz")
    p.add_argument("--tone", type=float, default=None, help="reference tone (Hz) for THD / response")
    p.add_argument("--nperseg", type=int, default=8192)
    p.add_argument("--plot", action="store_true", help="show PSD + spectrogram")
    p.add_argument("--save", default=None, help="save the figure to this path instead of showing")
    args = p.parse_args(argv)

    fs, y = load_signal(args.capture, args.channel)
    y = detrend_ac(y)
    dur = y.size / fs
    print(f"{args.capture}: {y.size} samples, {dur:.3f} s @ {fs:g} Hz", file=sys.stderr)

    from scipy.signal import welch

    f, pxx = welch(y, fs=fs, nperseg=min(args.nperseg, y.size), window="hann")
    peak_f = f[np.argmax(pxx)]
    print(f"spectral peak: {peak_f:.2f} Hz")

    if args.tone:
        r, amps = thd(y, fs, args.tone)
        print(f"THD @ {args.tone:g} Hz: {100*r:.2f} %")
        for k, a in amps.items():
            print(f"  h{k} ({k*args.tone:8.1f} Hz): {20*np.log10(a/amps[1] + 1e-20):7.1f} dBc")

    if args.plot or args.save:
        import matplotlib.pyplot as plt
        from scipy.signal import spectrogram

        fig, ax = plt.subplots(2, 1, figsize=(9, 7))
        ax[0].semilogy(f, pxx)
        ax[0].set(xlabel="Hz", ylabel="PSD (V²/Hz)", title=f"Welch PSD — {args.capture}")
        if args.tone:
            ax[0].axvline(args.tone, color="r", ls=":", lw=1)
        ax[0].grid(True, which="both", alpha=0.3)

        sf, st, sxx = spectrogram(y, fs=fs, nperseg=min(2048, y.size // 4 or 1))
        ax[1].pcolormesh(st, sf, 10 * np.log10(sxx + 1e-20), shading="auto")
        ax[1].set(xlabel="s", ylabel="Hz", title="Spectrogram (dB)")
        fig.tight_layout()
        if args.save:
            fig.savefig(args.save, dpi=120)
            print(f"wrote {args.save}", file=sys.stderr)
        else:
            plt.show()


if __name__ == "__main__":
    main()
