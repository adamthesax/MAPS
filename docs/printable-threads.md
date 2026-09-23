# Printable threads

Rules for every thread in `mapscam`. Most of them are enforced by code:
`print_thread()` in [`scad/lib/threads.scad`](../scad/lib/threads.scad) asserts the
numbers, and `make check-threads` (part of `make check`) fails the build on any printed
thread that bypasses the helper. The numbers live in `scad/lib/constants.scad` (`PT_*`).
They are tuned for a 0.4 mm nozzle at the 0.16 mm layers in
[print-settings.md](print-settings.md).

## Two kinds of thread

| Kind | Example | What to do |
|---|---|---|
| **Private printed pair**: both halves are printed, and nothing bought has to fit | receiver `lens_retainer` ↔ `barrel`, `filter_ring` ↔ `stem`, lens `retainer` ↔ `barrel` | `print_thread()` only. Profile, pitch, clearance and length are all yours to choose, so choose printable ones. |
| **Interchange**: has to mate a bought metal part | 1"-32 C-mount, Mxx×0.5 filter threads | Keep the standard ISO/UN profile. Call BOSL2 `threaded_rod()` directly with `// interchange: <standard>` in the 3 lines above it. Expect a marginal print (see [Interchange threads](#interchange-threads)). |

If you are not sure which kind a thread is, it is private.

## The rules

1. **Print with the thread axis vertical.** Each turn then goes down as a nearly flat
   ring, one layer on the next, with no supports. With the axis horizontal, the bottom
   of every turn is an unsupported overhang and the thread goes oval. If you really
   can't avoid it, BOSL2's `teardrop=` is the fallback, and the part will fit worse.
2. **Pitch ≥ 1.5 mm, and 2–2.5 mm is better** (`PT_MIN_PITCH`). A 0.4 mm nozzle lays a
   line about 0.45 mm wide. At 1 mm pitch or finer, each flank is only one or two lines
   and neighbouring turns merge. That leaves at least 9 layers per pitch at 0.16 mm.
   Larger diameters should use a coarser pitch: it is more forgiving of out-of-round.
3. **Always give clearance, and put it on the internal part.** Diametral
   clearance = `0.30 + 0.003·d` mm (`print_thread_clearance(d)`), so 0.35 at Ø17 and
   0.55 at Ø85. It grows with d because shrinkage and out-of-round both scale with the
   size of the circle. BOSL2's `$slop` defaults to **0**, so a raw `threaded_rod(internal=true)`
   at the same `d` as its male half gives a zero-clearance pair that will not assemble.
   Both halves take the same nominal `d`, and the internal cutter adds the clearance.
4. **Use 45° flanks, not 60°.** An ISO/UN 60° thread has flanks only 30° above
   horizontal, so printed axis-vertical every turn has a 60° overhang: droopy undersides
   and ragged roots. `print_thread()` cuts a 90° included-angle trapezoid instead. Its
   flanks sit at 45°, the steepest overhang FDM prints cleanly. It has flat crests and
   roots (0.15·P each) instead of knife edges, and a depth of 0.35·P (`PT_DEPTH_RATIO`).
5. **Thread length ≥ 3 pitches** (`PT_MIN_TURNS`). Blunt starts (rule 6) trim about half
   a turn at each end, which leaves about 2 working turns. That is plenty for a
   retaining ring clamping glass. Anything carrying real preload should use more turns,
   or a heat-set insert.
6. **Blunt starts, plus a bevel at both ends.** `print_thread()` always uses
   `blunt_start`, so there is no feather-edge partial turn left to cross-thread. It also
   bevels each end by one thread depth at 45°. The bevel gives a lead-in, and on the bed
   face it absorbs elephant's foot, the squashed first layer that otherwise binds the
   first turn. An internal thread whose mouth is on the bed gets its own 45° mouth
   flare too (see the receiver barrel).
   - **Exception:** never bevel an end that is a *depth stop*. Turn it off with
     `bevel1/bevel2 = false`. Example: the `filter_ring` shoulder lands exactly when its
     nose meets the filter. A bevel there would let it run on and load the glass.
7. **Fine facets.** `print_thread()` uses `$fa = 1, $fs = 0.4` (`PT_FA`, `PT_FS`), so chords
   are at most 0.4 mm. A coarse `$fn` on a big thread gives flat facets whose sag eats the
   clearance: `$fn = 64` at Ø85 means 4.2 mm chords.
8. **Size walls from the cut, not the nominal.** The wall behind an internal thread is
   measured from `print_thread_bore(d)` (nominal + clearance). The male's minor diameter,
   `print_thread_minor(d, pitch)`, is what has to clear any bore inside it. Write the
   `params.scad` asserts against those two, not against `d`.
9. **Minimum diameter: 8 mm** (`PT_MIN_D`). Smaller printed threads are only a few
   nozzle widths tall. Use a brass heat-set insert (`constants.scad`) instead.

## Slicer

On top of [print-settings.md](print-settings.md):
- 4 perimeters. The thread is all perimeter, and infill never reaches it.
- Slow outer wall for the threaded part. Put the seam **aligned / rear**, not random: a
  random seam puts a zit on every turn.
- Leave XY / hole compensation at the value tuned for the M3 insert pocket. Don't add
  extra compensation to "fix" a thread. Change `PT_CLEAR_BASE` instead, so the model
  stays the truth.
- Print both halves of a pair on the same printer in the same material. PETG shrinks
  about 0.3–0.5 %, which is ~0.3 mm on Ø85, and the clearance assumes both halves shrink
  alike.

## Tuning

Clearance is set by printer and material, and there are two knobs:
- **Every thread too tight or too loose:** change `PT_CLEAR_BASE` in `constants.scad`.
  Re-render both halves.
- **Only one thread is off:** pass `clearance =` to that `print_thread()` call (the
  internal half) and note why in a comment.

Before reprinting a big part, print a short test ring. Set `print_thread(l = 3·pitch)` on
a thin tube for both halves (minutes of printing, versus hours for the receiver barrel).

## Interchange threads

These have to take a bought metal part, so they keep the standard profile and pitch.
They are knowingly marginal on FDM:

| Thread | Pitch | Layers / pitch @ 0.16 | Advice |
|---|---|---|---|
| 1"-32 UN C-mount | 0.794 mm | 5 | Fine for prototypes. For anything you'll keep, use the captured metal ring build (`lens_mount_style = "ring"`, `docs/design-notes.md`). Chase with the actual lens. |
| Mxx×0.5 filter | 0.5 mm | 3 | Expect to chase it with the filter. Use a bought step ring if it matters. |

A raw BOSL2 call is still better with `bevel=true` at the lead-in end and a real
`thread_clearance`. Neither is automatic outside `print_thread()`.

## Case study: the vibrometer receiver retainer

The Ø84.6 thread that clamps the Ø80 optic printed badly. Everything that was wrong
with it is a rule above:

| Was | Rule | Now |
|---|---|---|
| male and female both at `d = 84.6`, `$slop = 0`, so **zero clearance** | 3 | internal cut at Ø85.15 (0.55 diametral) |
| 60° ISO profile, 2.0 mm pitch: 60° flank overhangs | 4, 2 | 45° flanks, 2.5 mm pitch, 0.875 mm deep, flat crests |
| `$fn = 64` at Ø85, 4.2 mm facets | 7 | ≤ 0.4 mm chords |
| no bevel on the ring's bed face, square mouth on the barrel's bed face | 6 | 45° bevel on both, plus a mouth flare |
| 6 mm ring = 3 turns, minus the blunt starts | 5 | 7.5 mm ring (3 × 2.5); the barrel cell is 1.5 mm longer |

The filter ring (Ø17 × 1.5) and the `lens` component's retainer (1.0 → 1.5 mm pitch)
moved onto `print_thread()` in the same change.

## Sources

- [Meshra — How to design 3D printed threads](https://meshra.ai/blog/design-3d-printed-threads):
  pitch vs nozzle, clearance ranges, trapezoidal over 60° V, axis-vertical orientation.
- [Snapmaker — Guide to designing and 3D printing threads](https://www.snapmaker.com/blog/3d-printing-threads/):
  45° lead-in chamfers on the screw and the nut mouth, trapezoidal profile, axis
  vertical, and clearance by offsetting one half (they shrink the male; we grow the
  female, which works the same way and keeps the male at its nominal size).
- [BOSL2 `threading.scad`](https://github.com/BelfrySCAD/BOSL2/wiki/threading.scad):
  `$slop` adds `4·$slop` to internal threads and is 0 by default. `blunt_start` is
  recommended for printing. The example "a 90° thread, resulting in 45° slopes friendly
  for 3D printing". The default blunt-start bevel is r/6, which is why `print_thread()`
  sizes its own.
- [JLC3DP — Considerations for 3D printing threads](https://jlc3dp.com/blog/considerations-for-3d-printing-threads):
  layer height as a fraction of pitch.
- [CNC Kitchen — M3–M10 printed thread test](https://www.printables.com/model/81211-m3-m10-3d-printed-thread-test):
  small printed threads are weak, so use inserts below ~M8.
