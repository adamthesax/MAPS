// Variant: 29 x 29 mm board, C-mount via a CAPTURED METAL RING (no printed thread).

include <../lib/params.scad>

mount_type        = "C";
lens_mount_style  = "ring";
ring_bore_d       = 25.6;   // measure your ring's OD and set this + ~0.1 mm
ring_depth        = 6.0;
ring_grubs        = 3;
board_x           = 29;
board_y           = 29;

include <../lib/dispatch.scad>
