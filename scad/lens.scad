// mapscam — printed lens barrel entry point and OpenSCAD Customizer target.
//
// Render one part, or the exploded assembly, by setting `part`
// (edit lib/lens/params.scad, use the Customizer, or pass -D on the command line):
//
//   OPENSCADPATH=vendor openscad -o stl/barrel.stl -D 'part="barrel"' scad/lens.scad
//
// Parts: assembly | barrel | retainer | hood
//
// For a whole named build (element dimensions, filter thread, ...) see
// components/lens/*.toml + scad/variants/*.scad and `make`.

include <lib/lens/params.scad>
include <lib/lens/dispatch.scad>
