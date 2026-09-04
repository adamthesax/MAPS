// Variant: 29 x 29 mm board, C-mount, printed 1"-32 thread.
// GUI: open this file. CLI: `make generic_29mm_c` or
//   OPENSCADPATH=vendor openscad -o out.stl -D 'part="body"' scad/variants/generic_29mm_c.scad

include <../lib/params.scad>

// --- overrides (OpenSCAD warns on the re-assignment; the last value wins) ---
mount_type        = "C";
lens_mount_style  = "thread";
board_x           = 29;
board_y           = 29;
board_hole_pitch_x = 22;
board_hole_pitch_y = 22;

include <../lib/dispatch.scad>
