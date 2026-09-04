---
name: tune-backfocus
description: Work the mapscam flange-focal-distance stack — given a sensor's PCB-to-active-surface number (or a measured focus error), compute the body length, standoff height and shim stack so the sensor lands at the C/CS flange focal distance. Use when the user mentions back focus, "can't reach infinity", flange distance, a sensor datasheet dimension, or focus that runs out of range.
---

# Tune back focus

## The model (all in `scad/lib/params.scad`, "computed" section)

```
sensor_z       = ffd(mount_type)                       # 17.526 (C) / 12.526 (CS)
pcb_front_z    = sensor_z - board_to_sensor_surface
pcb_back_z     = pcb_front_z + board_thickness
carrier_face_z = pcb_back_z + standoff_h
ledge_z        = carrier_face_z - shim_nominal
body_length    = carrier_back_z + rear_margin + rear_reg_h - front_mate_z
```

Only `body_length` and `ledge_z` are derived — everything else is a knob.

## From a datasheet number
1. Get `board_to_sensor_surface` = PCB front face → **sensor active surface** (cover glass
   top). Not the connector height. If the datasheet gives sensor-surface-to-mounting-hole,
   convert.
2. Set it in the variant file (or `-D`). Run `make check` then `make <variant>`.
3. Read the echoed `body_length`; that's the part that changed. Reprint the body.
4. `standoff_h` only needs changing if components on the PCB back would hit the carrier, or
   an `assert()` complains the stack is too short — then lower it.

## From a measured focus error (already printed)
- Lens hits infinity stop before sharp → sensor too far → **remove** shim (≈ error).
- Sharp only past infinity → too close → **add** shim, and if out of shim range increase
  `board_to_sensor_surface` understanding and reprint the body.
- Regenerate the shim sheet after changing `shim_values`: `make <variant>` (part `shims`).
- Full procedure for the user: `docs/calibration.md`.

## Guard rails
- Keep `shim_nominal` ≥ max single shim so shims can be *removed*, not only added.
- After any change, `make check` must stay green (the asserts catch impossible stacks).
- Record the final shim stack in the variant file as a comment and in the user's build log.
