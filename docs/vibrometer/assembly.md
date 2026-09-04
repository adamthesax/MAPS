# Vibrometer — assembly (Phase 1 self-mixing)

Prereqs: the stock camera enclosure printed (`front` with `mount_type = "blank"`,
`body`, `carrier`, `rear`, `shims`) plus the one vibrometer-specific part,
`laser_board`; the AFE PCB populated and bench-checked
([calibration.md](calibration.md)); the laser driver set to its current setpoint
with the laser **off**.

> **Laser safety first.** Class 3R. Do the optical alignment at low power, beam
> at not-eye height, block the far end. See
> [design-notes.md](design-notes.md#laser-safety).

## 1. Inserts

Exactly a `generic_29mm_c` camera:

- 8 × M3 heat-set into the stock body (4 front, 4 rear).
- 4 × M2 heat-set into the stock carrier standoff tops.
- If wall-mounting: 1 × ¼-20 into the rear cap edge.

## 2. Laser board optics

1. Press the **collimating lens** into its seat (`collimator_d` bore, ahead of
   the can pocket), convex side toward the laser.
2. Slide the **laser diode / collimator can** into the on-axis pocket from the
   **board (rear) side**; snug it with the **M2 grub screw** on +X. Do **not**
   fully tighten — focus is set by can depth.
3. Drop the **coverslip pick-off** into the 45° slot near the barrel tip. It
   sends a few % toward the BPW34 pocket in the barrel wall.
4. Press a **BPW34** into the barrel-wall pocket at the pick-off. This is the SMI
   detector (or use the laser can's internal monitor photodiode and keep the
   BPW34 as an external reference).
5. Route the laser leads and the BPW34 leads along the barrel, through the
   **wire pass-through** in the board plate, to the carrier / rear side.

## 3. Collimation + focus

1. Power the laser at low current. Project onto a wall ~2–5 m away.
2. Adjust the **can depth** until the spot is smallest / most uniform at working
   distance (collimated). Lock the grub screw.
3. Confirm the pick-off puts light on the BPW34: scope `OUT_DC` while blocking /
   unblocking the return beam — a clear DC step, and fringes with a moving target.

## 4. Stack it

1. **Laser board** onto the carrier standoffs, 4 × M2 — same holes a sensor PCB
   uses. The barrel points out the front (toward `front`).
2. Wire the AFE PCB to the laser + BPW34 leads; mount it on the carrier back (the
   `rear_margin` space) or run it external on the cable.
3. Carrier + laser board into the body, resting on the ledge. Shims optional —
   there is no back focus to hit; use them only to fine-set the barrel's exit
   plane if you care.
4. `front` onto the body: register engages, **+X index key** lines up, 4 × M3 × 8
   into the front inserts. The barrel passes through the front bore.
5. Cable gland into the rear cap; feed the cable; `rear` onto the body,
   4 × M3 × 12. Tighten the gland.

## 5. First light

- Aim at a matte target ~0.3–1 m away.
- `sw/vibrometer/capture.py --source <sound|teensy> --seconds 2 ...` then
  `fringe_count.py`.
- Tap the target / bench: fringe bursts and a non-zero velocity trace. Drive a
  piezo or speaker cone at a known amplitude to calibrate
  ([calibration.md](calibration.md)).
