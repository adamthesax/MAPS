# Vibrometer — electronics

Design detail for the two boards. The buildable source of truth is under
[`elec/`](../../elec/) (`elec/afe/README.md`, `elec/laser/README.md`, and the
`bom.csv` in each); this page is the "why".

## Analog front end (`elec/afe/`)

Converts BPW34 photocurrent to voltage with switchable gain and bandwidth, and
gives two outputs: `OUT_DC` (fringe counting / phase demod) and `OUT_AC`
(high-pass ~2 Hz, ±1 V for a sound card).

### Photodiode bias

Photoconductive, `VR ≈ 9–12 V` reverse. BPW34 junction capacitance falls from
~70 pF at 0 V to ~12–15 pF at 10 V — this is what buys the TIA its bandwidth and
linearity. A 9 V battery is the quietest source; a small boost off +5 V is fine
if filtered (ferrite + 10 µF + 100 nF).

### Transimpedance amp

`Rf` switch-selectable **100 kΩ / 1 MΩ / 10 MΩ**. Feedback cap for phase margin:

```
  f_p = 1 / (2π · Rf · Cf)
```

| Rf | Cf | pole | use |
|---|---|---|---|
| 100 kΩ | ~4.7 pF | ~340 kHz | strong return / Doppler |
| 1 MΩ | ~0.5 pF (+ stray) | ~200–500 kHz target | general SMI |
| 10 MΩ | ~1 pF | ~16 kHz | Phase 0 speckle, weak light |

Op-amp:

| Phase | Part | Why |
|---|---|---|
| 0 | OPA2340 / MCP662 / TLV2462 | FET input, fine to 20 kHz, cheap |
| 1 / 2 | **OPA657** (or OPA847) | 1.6 GHz GBW, 4.5 pF input C — clean fringes into the 100s of kHz |

Footprint both (SOIC-8 single + SOT-23-5, or a socketed daughtercard).

### Downstream

- 2nd stage: non-inverting ×10–×100, switch-selectable.
- Anti-alias: 4th-order Sallen-Key low-pass, corner **20 k / 100 k / 500 kHz**,
  matched to the DAQ Nyquist.
- `OUT_AC`: ~2 Hz high-pass + divider to ±1 V full scale.

### Noise budget

| Term | 1 MΩ Rf, 20 kHz BW |
|---|---|
| Rf Johnson | 0.13 pA/√Hz → ~18 pA rms |
| Shot noise, ~4 µA photocurrent | 1.1 pA/√Hz |
| Op-amp `e_n · (Cin/Cf)` | hold below Rf noise by keeping `Cin` down (the bias story) |

Resistor-limited at low light, shot-limited with a good return. At an
interferometric mid-fringe this is roughly **sub-nm displacement resolution in a
20 kHz band**.

## Laser driver (`elec/laser/`)

| Phase | Source | Driver |
|---|---|---|
| 0 | 650 nm 1–5 mW module, or bare diode | LM317 constant-current (~38 mA), soft-start, reverse + OV protection |
| 1 | single-mode 650 nm diode (HL6501MG-class) | low-noise **ACC** — iC-Haus iC-WKN / iC-HKB, or a servo'd discrete mirror; optional bias-T for the junction-voltage SMI cross-check |
| 2 | used HeNe + brick supply (or TEC-stabilised SM diode) | HeNe supply as-is, or LTC1923/DRV595 TEC loop on-board |

Run **constant current, not APC** for self-mixing — the APC loop fights the
self-mixing power modulation. Interlock, hard current limit and soft-start on
every build; scope for power-up overshoot.

## DAQ

| Backend | BW | Phase |
|---|---|---|
| PC sound card line-in | ≤ ~20 kHz | 0, slow 1 |
| USB audio ADC (PCM1808 @ 96 kHz) | ≤ ~40 kHz | 1 |
| Teensy 4 / RP2040 ADC over USB — [`sw/firmware/`](../../sw/firmware/) | 200 kHz–1 MHz | 1 Doppler, 2 |

Match `SAMPLE_HZ` in the firmware to `--fs` on `sw/vibrometer/capture.py`.
