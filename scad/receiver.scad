// mapscam — vibrometer receiver optic: entry point and OpenSCAD Customizer target.
//
// A large-aperture receiver telescope for the M.A.P.S. laser vibrometer: a bought
// Ø80 mm f≈150 mm singlet in a draw-tube focuser, feeding the returned beam through
// an 808 nm bandpass filter to a detector on a stock mapscam `body`.
//
//   OPENSCADPATH=vendor openscad -o stl/barrel.stl -D 'part="barrel"' scad/receiver.scad
//
// Parts: assembly | flange | stem | barrel | clamp | lens_retainer | filter_ring
// Focus: coarse draw-tube (barrel slides on stem, `clamp` locks) + fine helicoid
// (rotate `stem` on the `flange` boss, radial grub locks).
//
// For a whole named build (element size, focus range, filter) see
// components/receiver/*.toml + scad/variants/*.scad and `make`.

include <lib/receiver/params.scad>
include <lib/receiver/dispatch.scad>
