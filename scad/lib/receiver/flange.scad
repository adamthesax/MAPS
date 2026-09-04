// mapscam receiver — flange: the mapscam-body interface plate + the 808 nm filter
// cell + the male fine-focus helicoid boss the stem threads onto.
//
// Authored in the flange frame: z = 0 is the flange face that seats on the body,
// +Z runs into the body (register boss, bolt bosses, filter, detector), the
// helicoid boss runs to -Z. Interface geometry (register + 4-corner M3) is a
// verbatim copy of scad/lib/camera/interface.scad so any stock body bolts on.

include <params.scad>
include <helix.scad>
use <../util.scad>
use <../hardware.scad>

// --- interface primitives (mirror of camera/interface.scad) ---------------
module vr_corner_ears(h) {
    for (p = mate_screw_xy())
        translate([p[0], p[1], 0]) cylinder(h = h, d = ear_d);
}

module vr_reg_boss() {
    union() {
        rprism(reg_x - 2*reg_fit, reg_y - 2*reg_fit, reg_boss_h, r = max(0.5, corner_r - 1));
        translate([reg_x/2 - reg_fit - 1, 0, 0])
            rprism(3, 6, reg_boss_h, r = 0.6);
    }
}

module vr_mate_screws(h) {
    for (p = mate_screw_xy())
        translate([p[0], p[1], 0]) screw_clear("M3", h);
}

// --- the part ------------------------------------------------------------
module flange() {
    difference() {
        union() {
            rprism(outer_x, outer_y, flange_thk, r = corner_r);
            vr_corner_ears(flange_thk);
            translate([0, 0, flange_thk]) vr_reg_boss();
            // male fine-focus helicoid boss, hanging toward -Z
            translate([0, 0, -helix_boss_len])
                helix_male(helix_major, helix_boss_len, helix_pitch);
        }

        // light bore up through the boss to the field stop
        translate([0, 0, -helix_boss_len - 1])
            cylinder(h = helix_boss_len + 1 + fs_z0 + 0.01, d = draw_id, $fn = 48);

        // field stop -> filter pocket -> retainer thread, opening toward +Z
        translate([0, 0, fs_z0 - 0.01])
            cylinder(h = 1.4 + 0.02, d = filter_clear_d, $fn = 48);                 // field stop
        translate([0, 0, fs_z1 - 0.01])
            cylinder(h = flange_thk + reg_boss_h + 2, d = filter_pocket_d, $fn = 48); // filter seat + through
        translate([0, 0, filt_z1])
            helix_female_cut(fring_d, fring_engage, fring_pitch, depth = 0.9, slop = 0.35); // retainer thread

        // 4-corner mate screws + cap-head counterbores on the flange face
        vr_mate_screws(flange_thk + reg_boss_h + 1);
        for (p = mate_screw_xy())
            translate([p[0], p[1], -0.01]) cylinder(h = 2.5, d = M3_HEAD_D);
    }
}

flange();
