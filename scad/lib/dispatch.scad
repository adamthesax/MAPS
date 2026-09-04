// mapscam — part dispatch. Included after params (or after params + overrides).
// Renders the single part named by `part`, or the exploded assembly preview.

use <util.scad>
use <front_plate.scad>
use <body.scad>
use <sensor_carrier.scad>
use <rear_plate.scad>
use <base_mount.scad>
use <shims.scad>
use <c_mount.scad>

module pcb_ghost() {
    color([0.1, 0.5, 0.2, 0.35])
        translate([0, 0, pcb_front_z])
            rprism(board_x, board_y, board_thickness, r = 1);
}

if      (part == "front")   front_plate();
else if (part == "body")    body();
else if (part == "carrier") sensor_carrier();
else if (part == "rear")    rear_plate();
else if (part == "base")    base_mount();
else if (part == "shims")   shims();
else if (part == "spacer")  cs_spacer();
else {
    // exploded preview — parts pulled apart along Z so mating faces stay readable
    // and the union stays 2-manifold. Not meant for STL export.
    explode = 8;
    translate([0, 0, -explode])        front_plate();
    body();
    translate([0, 0,  explode * 0.4])  sensor_carrier();
    translate([0, 0,  explode])        rear_plate();
    % translate([0, 0, explode * 0.4]) pcb_ghost();
}
