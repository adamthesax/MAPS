# Vibrometer — bill of materials

Headline per phase. Board-level part lists: [`elec/afe/bom.csv`](../../elec/afe/bom.csv),
[`elec/laser/bom.csv`](../../elec/laser/bom.csv).

## Printed parts (Phase 1)

Every part except `laser_board` is the **stock `generic_29mm_c` part** — same
STL. The front plate is the stock C-mount front; the Ø16 mm bore passes the
laser barrel, and the 1"-32 thread is free for a screw-on window / filter.

| Part | Qty | `part=` | Orientation |
|---|---|---|---|
| Front plate | 1 | `front` | flange face down, thread-axis vertical |
| Body | 1 | `body` | register end down — **identical to `generic_29mm_c`, 26.6 mm** |
| Sensor carrier | 1 | `carrier` | standoffs up |
| **Laser board** | 1 | `laser_board` | barrel down, plate up, tree/organic supports under the barrel |
| Rear cap | 1 | `rear` | flat face down |
| Shim set | 1 sheet | `shims` | flat |
| Wall bracket | 0–1 | `base` | optional |

Render: `make vibrometer_smi_650`, or per-part
`OPENSCADPATH=vendor openscad -o stl/laser_board.stl -D 'part="laser_board"' scad/variants/vibrometer_smi_650.scad`.

## Fasteners & inserts (Phase 1)

Same as a `generic_29mm_c` camera, plus the laser-can grub screw.

| Item | Qty | Where |
|---|---|---|
| Heat-set insert M3 × L5 | 8 | stock body (4 front + 4 rear) |
| Heat-set insert M2 × L4 | 4 | stock carrier standoffs |
| Cap screw M3 × 8 | 4 | front → body |
| Cap screw M3 × 12 | 4 | rear cap → body |
| Screw M2 × 6–8 | 4 | laser board → carrier standoffs |
| Grub screw M2 × 4 | 1 | laser-can retention in the barrel |
| Cable gland PG7 | 1 | rear cap (`gland = "PG7"`) |

## Phase 0 — speckle (~$15–25)

BPW34 ×2 · op-amp (OPA2340) · resistors / caps · 9 V battery + clip · 650 nm
1–5 mW laser module · perfboard · a speaker + tone source for the check.

## Phase 1 — self-mixing (~$40–70)

Add: single-mode 650 nm diode + aspheric collimating lens · low-noise
constant-current driver parts (iC-WKN) · microscope coverslip (pick-off) ·
printed `laser_board` + the stock camera enclosure + gland · small AFE PCB ·
optional USB audio ADC · optional Teensy 4 / RP2040 for the fast-Doppler DAQ.

## Phase 2 — Michelson homodyne (~$150–300)

Add: used HeNe tube + brick supply (or a TEC-stabilised SM diode) · 50:50
beamsplitter cube · PZT + reference mirror · λ/4 waveplate + 2 polarizers ·
aluminium breadboard (25 mm grid) · 2–3 more BPW34 · Teensy DAQ.

## Optics — where to buy

| Item | Spec | Source class |
|---|---|---|
| Single-mode 650 nm diode | ~5–10 mW, TO-18 / 9 mm can | laser-diode distributors, salvage from a DVD-R writer (655 nm) |
| Aspheric collimating lens | f ≈ 4.5 mm, NA ≥ 0.3, mounted or bare Ø6.35 | Thorlabs C-series, or a salvaged optical-drive collimator |
| Coverslip pick-off | 18 × 18 mm, #1 thickness (~0.15 mm) or a 1 mm slide | microscopy supplies |
| Protective window | Ø12 × 0.5 mm, AR if possible | optics distributors |
