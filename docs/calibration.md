# Back-focus calibration

Goal: the sensor plane sits exactly one flange-focal-distance behind the lens flange, so the
lens reaches **infinity focus** with its focus ring near — not jammed against — its infinity
stop, and its full focus range is usable.

## Symptoms

| What you see | Likely cause | Fix |
|---|---|---|
| Can't reach sharp focus on a distant target; ring hits the infinity stop first | sensor too **far** from flange (FFD too long) | **remove** shims |
| Distant target sharp only with the ring well **past** infinity | sensor too **close** (FFD too short) | **add** shims |
| Sharp in the centre, soft at edges, tilts across frame | sensor not perpendicular | reprint ledge/carrier flat; check PCB seating |
| Never sharp anywhere | wrong lens image circle, or debris on sensor | — |

## Procedure

1. Aim at a **high-contrast target ≥ 50 × focal length away** (outdoors, or a detailed wall
   across a room). Open the aperture fully (worst-case depth of field — most sensitive).
2. Set the lens focus ring **to its infinity mark** and lock nothing yet.
3. Look at a live view at 100 %. If it is not sharp:
   - Sharpest with ring **before** infinity → remove ~0.2 mm of shim.
   - Can't get there, ring at the stop → add ~0.2 mm of shim.
4. Reassemble, repeat. Converge to within one 0.1 mm shim.
5. Fine-trim with the focus ring, then **lock the ring** (grub screw or paint).
6. Record the final shim stack in your build log / the variant's notes.

## If you run out of shim range

- Check the `echo`ed `carrier_face_z` against a caliper measurement of the printed carrier
  + standoffs. A consistent offset means a print-scale or `board_to_sensor_surface` error —
  correct the parameter and reprint the body rather than stacking shims.
- The `board_to_sensor_surface` value is the usual culprit: it is the distance from the PCB
  front face to the **sensor active surface** (top of the cover glass / die), from the
  sensor datasheet — not the PCB-to-connector height.
