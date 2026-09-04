// mapscam — front module: lens interface + register boss into the body.

include <params.scad>
use <interface.scad>
use <c_mount.scad>
use <../util.scad>
use <../hardware.scad>

module front_plate() {
    difference() {
        union() {
            rprism(outer_x, outer_y, front_base_thk, r = corner_r);
            corner_ears(front_base_thk);
            translate([0, 0, front_base_thk]) reg_boss();
            lens_tower(0);
        }
        lens_bore();
        lens_interface_cut(0);
        // mate screws pass through the plate into the body's front inserts
        mate_screws("clear", h = front_base_thk + reg_boss_h + 1);
        // cap-head recess on the flange (front) face
        for (p = mate_screw_xy())
            translate([p[0], p[1], 0]) cap_counterbore("M3", 2.5);
    }
}

front_plate();
