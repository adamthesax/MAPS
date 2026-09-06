// mapscam — laser vibrometer, entry point and OpenSCAD Customizer target.
//
// The vibrometer is the STOCK camera enclosure with the CMOS sensor PCB replaced
// by a printed `laser_board`. Render one part, or the exploded assembly, by
// setting `part` (edit lib/vibrometer/params.scad, use the Customizer, or pass
// -D on the command line):
//
//   OPENSCADPATH=vendor openscad -o stl/laser_board.stl -D 'part="laser_board"' scad/vibrometer.scad
//
// Parts: assembly | front | body | carrier | laser_board | rear | base | shims
// (front / body / carrier / rear / base / shims are the stock camera parts.)
//
// Design + electronics + software: docs/vibrometer/.

include <lib/vibrometer/params.scad>
include <lib/vibrometer/dispatch.scad>
