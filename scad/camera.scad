// mapscam — top-level entry point and OpenSCAD Customizer target.
//
// Render one part, or the whole assembly, by setting `part`
// (edit params.scad, use the Customizer, or pass -D on the command line):
//
//   OPENSCADPATH=vendor openscad -o stl/body.stl -D 'part="body"' scad/camera.scad
//
// Parts: assembly | front | body | carrier | rear | base | shims | spacer
//
// For a whole named build (specific board size, mount type, ...) see
// scad/variants/*.scad and `make`.

include <lib/params.scad>
include <lib/dispatch.scad>
