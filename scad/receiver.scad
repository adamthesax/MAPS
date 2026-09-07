// mapscam — vibrometer receiver optic: entry point and OpenSCAD Customizer target.
//
// A large-aperture receiver telescope for the M.A.P.S. laser vibrometer: a bought
// Ø80 mm f≈150 mm optic in a fixed-length tube, feeding the returned beam through
// an 808 nm bandpass filter to a detector on a stock mapscam camera.
//
//   OPENSCADPATH=vendor openscad -o stl/barrel.stl -D 'part="barrel"' scad/receiver.scad
//
// Parts: assembly | stem | barrel | lens_retainer | filter_ring
// Fixed focus for now: `stem` (camera interface + filter) plugs into the rear of
// `barrel` (holds the optic) and is pinned with 3 screws. By default `stem` ends in
// a male 1"-32 thread and screws into a stock generic_29mm_c front plate
// (mount = "C"); mount = "flange" gives it a bolt-on front plate instead.
//
// For a whole named build (element size, focus range, filter) see
// components/receiver/*.toml + scad/variants/*.scad and `make`.

include <lib/receiver/params.scad>
include <lib/receiver/dispatch.scad>
