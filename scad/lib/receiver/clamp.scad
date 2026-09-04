// mapscam receiver — focus clamp: a wrap-around split collar that squeezes the
// barrel's slit collet onto the stem. One tangential pinch screw closes the split;
// the ring also covers the collet relief slots, so it doubles as a light seal.
//
// Authored z = 0 .. clamp_h; slides onto the barrel collet from the rear.

include <params.scad>
use <../util.scad>
use <../hardware.scad>

module clamp() {
    ear_reach = clamp_od/2 + 9;     // how far the pinch ears stand out past +X
    ear_tan   = 8;                  // ear thickness (tangential)
    gap       = clamp_relief;       // split width
    scr_z     = clamp_h / 2;
    scr_x     = clamp_od/2 + 3;     // pinch screw sits just outside the ring OD

    difference() {
        union() {
            cylinder(h = clamp_h, d = clamp_od);
            // one solid ear block across the split; the slot below splits it in two
            translate([0, -(gap/2 + ear_tan), 0])
                cube([ear_reach, 2*(gap/2 + ear_tan), clamp_h]);
        }

        // bore that grips the collet
        translate([0, 0, -1]) cylinder(h = clamp_h + 2, d = clamp_id);

        // +X split, right through ring + ear block
        translate([-1, -gap/2, -1]) cube([ear_reach + 2, gap, clamp_h + 2]);

        // tangential pinch screw: clearance one ear, hex nut trap the other
        translate([scr_x, gap/2 + ear_tan + 2, scr_z]) rotate([90, 0, 0])
            cylinder(h = 2*ear_tan + gap + 5, d = clamp_screw_clear);
        translate([scr_x, -(gap/2 + ear_tan) + ear_tan*0.55, scr_z]) rotate([90, 0, 0])
            cylinder(h = ear_tan * 0.75, d = clamp_nut_af / cos(30) + 0.4, $fn = 6);
        // screw-head counterbore on the +Y ear
        translate([scr_x, gap/2 + ear_tan + 0.01, scr_z]) rotate([90, 0, 0])
            cylinder(h = 3.0, d = clamp_nut_af / cos(30) + 1.6);
    }
}

clamp();
