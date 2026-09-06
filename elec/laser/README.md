# 650 nm laser driver (`elec/laser`)

Constant-current source for the vibrometer laser. Class 3R handling — see
`docs/vibrometer/design-notes.md` "Laser safety".

## Phase 0 — cheap and disposable

Any 650 nm 1–5 mW diode module *with its own driver*, or a bare diode on an
**LM317 constant-current sink**:

```
  +Vin (5..9 V) ──[ LM317 ]── Radj ──┬──► LD_A
                    │ ADJ            │
                    └───────/\/\─────┘
                            Rset = 1.25 / Iset      (e.g. 33 Ω → ~38 mA)
  LD_K ── GND
```

Add: a **slow-start** (10 µF from ADJ to OUT), a **series Schottky** for reverse
protection, and a **TVS / 12 V zener** across the diode. That is enough to bring
up Phase 0.

## Phase 1 — low-noise driver for self-mixing

Self-mixing rides on the laser's own output power, so driver current noise and
back-reflection stability matter.

- **Diode:** a real **single-mode 650 nm laser diode** (e.g. HL6501MG-class,
  ~5–10 mW), visible for alignment, coherence length ≫ a bench standoff. *Not* a
  pointer module.
- **Driver:** dedicated low-noise constant-current IC — **iC-Haus iC-WKN** or
  **iC-HKB**, or a clean discrete current mirror with an op-amp servo on a sense
  resistor. Target noise < 1 µA rms in-band.
- **Bias-T option:** a bias-T on the diode lets you also read the
  **junction-voltage SMI signal** as a cross-check against the BPW34 channel
  (`LD_ACJ` output).
- **Protection on every build:** interlock header, hard current limit, soft-start,
  no power-up overshoot (scope the monitor PD or a 1 Ω sense).
- **APC vs ACC:** run **ACC** (constant current) for SMI — APC's feedback loop
  fights the self-mixing modulation.

## Phase 2 — Michelson source

Low-risk: a **used HeNe tube + brick supply** (632.8 nm, coherence length
~0.2 m+, excellent amplitude/frequency stability). Alternative: a
**temperature-controlled single-mode diode** — add a TEC + 10 kΩ NTC + a
TEC controller (e.g. LTC1923 / DRV595) on this board.

`bom.csv` covers Phase 0 + Phase 1.
