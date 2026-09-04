// mapscam vibrometer — part dispatch. Included after params (or params + overrides).
//
// The vibrometer is the STOCK camera enclosure — front / body / carrier / rear /
// base / shims all come straight from scad/lib/camera/, unchanged — with the
// CMOS sensor PCB replaced by a printed `laser_board` on the carrier standoffs.

use <../util.scad>
use <../camera/front_plate.scad>
use <../camera/body.scad>
use <../camera/sensor_carrier.scad>
use <../camera/rear_plate.scad>
use <../camera/base_mount.scad>
use <../camera/shims.scad>
use <../camera/c_mount.scad>
use <laser_board.scad>

if      (part == "front")       front_plate();
else if (part == "body")        body();
else if (part == "carrier")     sensor_carrier();
else if (part == "laser_board") laser_board();
else if (part == "rear")        rear_plate();
else if (part == "base")        base_mount();
else if (part == "shims")       shims();
else {
    // exploded preview — parts pulled apart along Z so mating faces stay readable.
    // Not meant for STL export.
    explode = 8;
    translate([0, 0, -explode])        front_plate();
    body();
    translate([0, 0,  explode * 0.4])  laser_board();
    translate([0, 0,  explode * 0.7])  sensor_carrier();
    translate([0, 0,  explode])        rear_plate();
}
