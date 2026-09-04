// mapscam receiver — stem: the interface flange + the narrow draw tube the
// lens barrel telescopes over + the 808 nm filter cell.
//
// Authored in the flange frame: z = 0 is the flange face that seats on the body,
// +Z runs into the body (register boss, bolt bosses), the draw tube runs to -Z.
// Interface geometry (register + 4-corner M3) is a verbatim copy of
// scad/lib/camera/interface.scad so any stock mapscam body bolts straight on.

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
            // interface flange
            rprism(outer_x, outer_y, flange_thk, r = corner_r);
            vr_corner_ears(flange_thk);
            translate([0, 0, flange_thk]) vr_reg_boss();
            // draw tube, hanging toward -Z
            translate([0, 0, -stem_len]) cylinder(h = stem_len, d = draw_od);
            // small fillet where the tube meets the flange
            translate([0, 0, -wall]) cylinder(h = wall, d1 = draw_od, d2 = draw_od + 2*wall);
        }

        // clear bore up the stem (stops at the field stop just under the flange)
        translate([0, 0, -stem_len - 1])
            cylinder(h = stem_len + 1 + filter_z0, d = draw_id);

        // field stop -> filter pocket -> retainer thread, opening toward +Z
        translate([0, 0, filter_z0 - 0.01])
            cylinder(h = flange_thk + reg_boss_h + 1, d = filter_pocket_d);          // filter seat + through
        translate([0, 0, -0.01])
            cylinder(h = filter_z0 + 0.02, d = filter_clear_d);                      // field stop
        translate([0, 0, filter_z1 + fring_engage/2 - 0.01])
            threaded_rod(d = fring_d + 2*0.2, l = fring_engage + 0.02,
                         pitch = fring_pitch, internal = true, $fn = 64);            // retainer thread

        // 4-corner mate screws + cap-head counterbores on the flange face
        vr_mate_screws(flange_thk + reg_boss_h + 1);
        for (p = mate_screw_xy())
            translate([p[0], p[1], -0.01]) cylinder(h = 2.5, d = M3_HEAD_D);
    }
}

stem();
