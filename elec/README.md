# `elec/` — M.A.P.S. vibrometer electronics

Two boards, shared across all three phases:

| Dir | Board | Status |
|---|---|---|
| [`afe/`](afe/) | BPW34 transimpedance analog front end | Phase 0 perfboard documented; KiCad 2-layer to follow |
| [`laser/`](laser/) | 650 nm constant-current laser driver | Phase 0 LM317 documented; low-noise Phase-1 driver specified |

Each directory has a `README.md` (design, values, noise budget, an ASCII
schematic) and a `bom.csv`. KiCad projects (`*.kicad_pro` / `*.kicad_sch` /
`*.kicad_pcb`) land here as they are drawn — the READMEs are the source of truth
until then, and the perfboard builds are enough to bring up Phase 0 / Phase 1.

Full itemised, part-numbered BOM per phase: [`docs/vibrometer/bom.md`](../docs/vibrometer/bom.md).

## Conventions

- Analog rails: `+5VA` / `-5VA` (or single `+5VA` + a mid-supply reference `VREF`).
  Keep the TIA on its own filtered node (`+5VT`).
- Photodiode bias net: `VR` (photoconductive, 9–12 V reverse).
- Signal nets out of the AFE: `OUT_DC` (buffered, for fringe/phase demod) and
  `OUT_AC` (high-pass ~2 Hz, scaled ±1 V for a sound card).
- Laser: `LD_A` / `LD_K`, monitor photodiode `LD_MPD` if the can has one.
