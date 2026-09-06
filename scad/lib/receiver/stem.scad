// mapscam receiver — stem: the mapscam-body interface plate + the 808 nm filter
// cell + a short rigid neck whose front end plugs into the barrel rear.
//
// Authored in the flange frame: z = 0 is the flange face that seats on the body,
// +Z runs into the body (register boss, bolt bosses, filter, detector), the neck
// runs to -Z. Interface geometry (register + 4-corner M3) is a verbatim copy of
// scad/lib/camera/interface.scad so any stock body bolts on.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
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
module stem() {
    difference() {
        union() {
            rprism(outer_x, outer_y, flange_thk, r = corner_r);
            vr_corner_ears(flange_thk);
            translate([0, 0, flange_thk]) vr_reg_boss();
            // rigid neck, hanging toward -Z (its front join_len is the barrel plug)
            translate([0, 0, stem_end_z]) cylinder(h = -stem_end_z, d = neck_od);
            // fillet where the neck meets the flange
            translate([0, 0, -wall]) cylinder(h = wall, d1 = neck_od, d2 = neck_od + 2*wall);
        }

        // clear bore up the neck to the field stop
        translate([0, 0, stem_end_z - 1])
            cylinder(h = -stem_end_z + 1 + fs_z0 + 0.01, d = neck_bore);
        // lead-in chamfer at the neck tip (eases the plug into the socket)
        translate([0, 0, stem_end_z - 0.01])
            cylinder(h = 2, d1 = neck_od + 1, d2 = neck_od - 3);

        // field stop -> filter pocket -> retainer thread, opening toward +Z
        translate([0, 0, -0.01])
            cylinder(h = fs_z0 + 0.02, d = filter_clear_d, $fn = 48);
        translate([0, 0, fs_z1 - 0.01])
            cylinder(h = flange_thk + reg_boss_h + 2, d = filter_pocket_d, $fn = 48);
        translate([0, 0, filt_z1 + fring_engage/2])
            threaded_rod(d = fring_d + 0.4, l = fring_engage + 0.02,
                         pitch = fring_pitch, internal = true, $fn = 48);

        // shallow groove around the plug for the barrel's 3 join-screw tips
        translate([0, 0, stem_end_z + join_len/2])
            rotate_extrude($fn = $fn)
                translate([neck_od/2 - 0.7, 0]) circle(d = 2.6, $fn = 20);

        // 4-corner mate screws + cap-head counterbores on the flange face
        vr_mate_screws(flange_thk + reg_boss_h + 1);
        for (p = mate_screw_xy())
            translate([p[0], p[1], -0.01]) cylinder(h = 2.5, d = M3_HEAD_D);
    }
}

stem();
