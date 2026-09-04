// mapscam — body module: parametric tube whose length is SOLVED from the
// flange-focal-distance stack budget (see params.scad `body_length`).

include <params.scad>
use <interface.scad>
use <../util.scad>
use <../hardware.scad>

module body() {
    fz = front_mate_z;
    bl = body_length;
    cav_r = max(0.5, corner_r - wall);

    union() {
        difference() {
            union() {
                translate([0, 0, fz]) rprism(outer_x, outer_y, bl, r = corner_r);
                translate([0, 0, fz]) corner_ears(bl);
            }
            // main cavity
            translate([0, 0, fz - 1])
                rprism(outer_x - 2*wall, outer_y - 2*wall, bl + 2, r = cav_r);
            // front register pocket (accepts the front plate boss)
            translate([0, 0, fz]) reg_pocket();
            // rear register pocket (accepts the rear cap boss)
            translate([0, 0, fz + bl]) mirror([0, 0, 1]) reg_pocket();
            // heat-set pockets: front inserts open toward -Z, rear open toward +Z
            translate([0, 0, fz])      mate_screws("insert-down");
            translate([0, 0, fz + bl]) mate_screws("insert-up");
        }

        // carrier support ledge: two ribs on the +/-X inner walls, top face at ledge_z
        for (sx = [-1, 1])
            translate([sx * (outer_x/2 - wall - 1.5), 0, ledge_z - ledge_thk])
                rprism(3, carrier_y - 6, ledge_thk, r = 0.6);
    }
}

body();
