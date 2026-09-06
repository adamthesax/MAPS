"""Shared helpers for the M.A.P.S. laser-vibrometer tools.

Kept dependency-light: numpy + scipy only. No plotting, no I/O backends.
"""
from __future__ import annotations

import numpy as np

# --- laser wavelengths (m) -------------------------------------------------
WAVELENGTHS = {
    "650nm": 650e-9,   # Phase 1 visible single-mode diode
    "685nm": 685e-9,
    "785nm": 785e-9,
    "hene": 632.8e-9,  # Phase 2 HeNe
}


def wavelength(name: str) -> float:
    """Resolve a wavelength name ('650nm', 'hene', ...) or a bare number in metres/nm."""
    if name in WAVELENGTHS:
        return WAVELENGTHS[name]
    v = float(name)
    return v * 1e-9 if v > 1e-3 else v   # accept "650e-9" or "650"


# --- displacement / velocity scale factors -------------------------------
def half_wave(lam: float) -> float:
    """Displacement per self-mixing fringe: one fringe == lambda/2 of round-trip path."""
    return lam / 2.0


def fringe_rate_to_velocity(f_fringe: np.ndarray | float, lam: float) -> np.ndarray | float:
    """Line-of-sight velocity from the instantaneous fringe rate: v = (lambda/2) * f."""
    return half_wave(lam) * np.asarray(f_fringe)


# --- .npz container ------------------------------------------------------
def save_npz(path: str, fs: float, **channels: np.ndarray) -> None:
    """Save one or more equal-length signal channels plus the sample rate."""
    np.savez_compressed(path, fs=np.float64(fs), **channels)


def load_npz(path: str) -> tuple[float, dict[str, np.ndarray]]:
    """Return (fs, {name: array}) from a .npz written by save_npz or capture.py."""
    d = np.load(path)
    fs = float(d["fs"])
    chans = {k: d[k] for k in d.files if k != "fs"}
    return fs, chans


def load_signal(path: str, channel: str | None = None) -> tuple[float, np.ndarray]:
    """Convenience: pull a single 1-D channel (the first, or a named one) from a .npz/.wav."""
    if path.lower().endswith(".wav"):
        from scipy.io import wavfile

        fs, data = wavfile.read(path)
        if data.ndim > 1:
            data = data[:, 0]
        if np.issubdtype(data.dtype, np.integer):
            data = data.astype(np.float64) / np.iinfo(data.dtype).max
        return float(fs), data
    fs, chans = load_npz(path)
    if channel is not None:
        return fs, chans[channel]
    key = "y" if "y" in chans else next(iter(chans))
    return fs, chans[key]


# --- signal helpers ----------------------------------------------------
def detrend_ac(x: np.ndarray) -> np.ndarray:
    """Remove DC / slow drift for spectral work."""
    from scipy.signal import detrend

    return detrend(x, type="constant")


def bandpass(x: np.ndarray, fs: float, lo: float, hi: float, order: int = 4) -> np.ndarray:
    """Zero-phase Butterworth band-pass."""
    from scipy.signal import butter, sosfiltfilt

    nyq = fs / 2.0
    hi = min(hi, 0.99 * nyq)
    sos = butter(order, [lo / nyq, hi / nyq], btype="band", output="sos")
    return sosfiltfilt(sos, x)


def analytic_phase(x: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Hilbert analytic signal -> (envelope, unwrapped instantaneous phase)."""
    from scipy.signal import hilbert

    z = hilbert(x)
    return np.abs(z), np.unwrap(np.angle(z))
