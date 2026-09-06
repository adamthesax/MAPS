#!/usr/bin/env python3
"""Round-trip checks for the vibrometer analysis path — no hardware, no pytest.

    python test_pipeline.py      # exits non-zero on failure
"""
from __future__ import annotations

import sys
import tempfile
from pathlib import Path

import numpy as np

from capture import capture_sim
from fringe_count import reconstruct
from homodyne import heydemann
from vibrolib import save_npz, wavelength


def check(name, cond, detail=""):
    print(f"[{'PASS' if cond else 'FAIL'}] {name}  {detail}")
    return cond


def test_speckle_thd():
    from analyze import thd

    fs, tone = 48000, 1000.0
    y = capture_sim(2.0, fs, tone, "650nm", mode="speckle")
    r, amps = thd(y, fs, tone)
    return check("speckle THD ~5 %", 0.03 < r < 0.08, f"(got {r*100:.1f} %)")


def test_smi_velocity():
    fs, tone, v_mean = 250000, 800.0, 2e-3
    lam = wavelength("650nm")
    y = capture_sim(1.0, fs, tone, "650nm", v_mean=v_mean, mode="smi")
    _, _, x, v, n = reconstruct(y, fs, lam, 200, 100000)
    t = np.arange(x.size) / fs
    v_rec = np.polyfit(t, x, 1)[0]
    ok_v = abs(v_rec - v_mean) / v_mean < 0.02
    ok_n = abs(n - v_mean / (lam / 2)) / (v_mean / (lam / 2)) < 0.02
    return check("SMI mean velocity within 2 %", ok_v, f"(got {v_rec*1e3:.4f} mm/s)") & check(
        "SMI fringe count within 2 %", ok_n, f"(got {n:.1f})"
    )


def test_homodyne_ellipse():
    fs = 50000
    lam = wavelength("hene")
    t = np.arange(fs) / fs
    x = 300e-9 * np.sin(2 * np.pi * 90 * t) + 40e-9 * np.sin(2 * np.pi * 300 * t)
    phi = 4 * np.pi * x / lam
    rng = np.random.default_rng(0)
    I = 1.15 * np.cos(phi) + 0.06 + 0.003 * rng.standard_normal(t.size)
    Q = 0.92 * np.sin(phi + 0.15) - 0.04 + 0.003 * rng.standard_normal(t.size)
    Ip, Qp = heydemann(I, Q)
    phi_rec = np.unwrap(np.arctan2(Qp, Ip))
    x_rec = lam / (4 * np.pi) * phi_rec
    x_rec -= x_rec.mean()
    err = np.std(x_rec - (x - x.mean())) / np.std(x)
    return check("homodyne displacement error < 5 %", err < 0.05, f"(got {err*100:.1f} %)")


def test_npz_roundtrip():
    with tempfile.TemporaryDirectory() as d:
        p = Path(d) / "r.npz"
        a = np.arange(10.0)
        save_npz(str(p), 1000.0, y=a)
        from vibrolib import load_signal

        fs, y = load_signal(str(p))
        return check("npz round-trip", fs == 1000.0 and np.allclose(y, a))


if __name__ == "__main__":
    results = [
        test_npz_roundtrip(),
        test_speckle_thd(),
        test_smi_velocity(),
        test_homodyne_ellipse(),
    ]
    sys.exit(0 if all(results) else 1)
