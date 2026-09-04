// mapscam — vibrometer receiver optic: entry point and OpenSCAD Customizer target.
//
// A large-aperture receiver telescope for the M.A.P.S. laser vibrometer: a bought
// Ø80 mm f≈150 mm singlet in a draw-tube focuser, feeding the returned beam through
// an 808 nm bandpass filter to a detector on a stock mapscam `body`.
//
//   OPENSCADPATH=vendor openscad -o stl/stem.stl -D 'part="stem"' scad/receiver.scad
//
// Parts: assembly | stem | barrel | lens_retainer | filter_ring
//
// For a whole named build (element size, focus range, filter) see
// components/receiver/*.toml + scad/variants/*.scad and `make`.

include <lib/receiver/params.scad>
include <lib/receiver/dispatch.scad>
