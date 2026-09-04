// Variant: 29 x 29 mm board, CS-mount (5.000 mm shorter flange focal distance).
// The body auto-shortens by 5 mm vs the C-mount build.

include <../lib/params.scad>

mount_type        = "CS";
lens_mount_style  = "thread";
board_x           = 29;
board_y           = 29;

include <../lib/dispatch.scad>
