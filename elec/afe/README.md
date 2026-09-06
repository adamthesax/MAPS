# BPW34 analog front end (`elec/afe`)

Shared by every phase. Converts BPW34 photocurrent to a low-noise voltage with
switchable transimpedance gain and a switchable anti-alias corner, and provides
both a DC-coupled output (fringe counting / phase demod) and an AC-coupled output
(±1 V for a sound card / audio ADC).

## Stages

```
                 VR (+9..+12 V, photoconductive bias)
                  │
             ┌────┴────┐
   light ───►│  BPW34   │            Rf (100k / 1M / 10M)     Cf
             └────┬────┘        ┌─────────/\/\──────┬──┤├──┐
                  │  Ipd        │                   │      │
                  ├─────────────┤ −  U1             ├──────┴─── OUT_TIA
                  │            ┌┤ +  (OPA2340 P0 /  │
                 GND           │└──  OPA657  P1/2)  │
                             VREF                   │
                                                    │
   OUT_TIA ──►[ x10..x100 gain, U2 ]──►[ 4th-order Sallen-Key LPF, U3 ]──┬──► OUT_DC
                                          fc = 20k / 100k / 500k         │
                                                                         └──[ HPF ~2 Hz, x-scale ]──► OUT_AC
```

- **Photodiode bias.** Photoconductive, `VR ≈ 9–12 V`. Drops BPW34 junction
  capacitance from ~70 pF (0 V) to ~12–15 pF — required for the TIA bandwidth and
  linearity. Bias from a 9 V battery (quietest) or a small boost off +5 V.
- **TIA (U1).** `Rf` switch-selectable **100 kΩ / 1 MΩ / 10 MΩ**. Feedback cap
  `Cf` sized per range for phase margin: `f_p = 1/(2π·Rf·Cf)`, target ~200–500 kHz
  on the 1 MΩ range → `Cf ≈ 0.3–0.8 pF` (use board stray + a trimmer, or 0.5 pF).
  On 10 MΩ, `Cf ≈ 1 pF` → ~16 kHz. On 100 kΩ, ~2–5 pF.
  - **Phase 0 op-amp:** FET-input jellybean — OPA2340, MCP662, or TLV2462. Fine to
    20 kHz.
  - **Phase 1/2 op-amp:** **OPA657** (1.6 GHz GBW, 4.5 pF input C) or OPA847.
    Needed for clean fringe signals into the 100s of kHz (Doppler beat of a
    few-mm/s target).
  - Footprint **both**: SOIC-8 (OPA657 single) + SOT-23-5, or a socketed daughter.
- **Second stage (U2).** Non-inverting ×10–×100, switch-selectable.
- **Anti-alias (U3).** 4th-order Sallen-Key low-pass, corner selectable
  **20 kHz / 100 kHz / 500 kHz** (match to the DAQ Nyquist).
- **Outputs.** `OUT_DC` buffered straight through; `OUT_AC` via a ~2 Hz high-pass
  and a divider so full-scale vibration ≈ ±1 V into a line input.

## Noise budget (sanity)

| Source | On 1 MΩ Rf, 20 kHz BW |
|---|---|
| Rf Johnson noise | 0.13 pA/√Hz → ≈ 18 pA rms |
| Shot noise on ~4 µA photocurrent | 1.1 pA/√Hz |
| Op-amp voltage noise × (Cin/Cf) | keep < Rf noise by holding Cin down (that is the bias story) |

Resistor-limited at low light, shot-limited with a good return — acceptable. At an
interferometric mid-fringe this is roughly **sub-nm displacement resolution in a
20 kHz band** with a decent return beam.

## Power

±5 V (or single +5 V + `VREF` mid-supply) from USB or a bench supply via LDOs.
Separate filtered rail (`+5VT`, ferrite + 10 µF + 100 nF) for U1. Star ground at
the TIA.

## Phase 0 perfboard build

1. BPW34 with short leads, cathode to `VR`, anode to the U1 summing node.
2. U1 = OPA2340, `Rf = 1 MΩ`, `Cf = 2.2 pF` NP0 across it. `+in` to a 2.5 V
   divider (`VREF`) off +5 V, well decoupled.
3. U2 = second OPA2340 half, non-inverting ×22 (1 kΩ / 21 kΩ).
4. One RC low-pass at ~22 kHz on the output; skip the Sallen-Key for Phase 0.
5. `OUT_AC` = 10 µF series + 100 kΩ to ground → sound-card line in.
6. Dark test, then modulated-LED test (see `docs/vibrometer/calibration.md`).

`bom.csv` in this directory is the Phase-0 + Phase-1 parts list.
