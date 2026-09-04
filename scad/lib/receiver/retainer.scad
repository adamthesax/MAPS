// mapscam receiver — the two clamp rings.
//   lens_retainer : plain ring, drops into the barrel ahead of the Ø80 optic and
//                   is held by the barrel's 3 radial M3 set screws (groove in OD).
//   filter_ring   : small threaded ring, clamps the 808 nm filter in the stem.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>

module lens_retainer() {
    ring_od = pocket_bore - 0.4;      // slip fit in the pocket
    difference() {
        cylinder(h = retainer_thk, d = ring_od);
        translate([0, 0, -0.01]) cylinder(h = retainer_thk + 0.02, d = clear_aperture_d);
        // V-groove around the OD for the set-screw tips
        translate([0, 0, retainer_thk/2])
            rotate_extrude($fn = $fn)
                translate([ring_od/2 - 0.6, 0])
                    circle(d = 2.4, $fn = 24);
        // two spanner notches in the front face
        for (a = [0, 90])
            rotate([0, 0, a]) translate([0, 0, retainer_thk - 1.0])
                cube([ring_od + 2, 2.0, 2.2], center = true);
    }
}

module filter_ring() {
    ring_h = fring_engage + 2.5;
    difference() {
        translate([0, 0, ring_h/2])
            threaded_rod(d = fring_d, l = ring_h, pitch = fring_pitch,
                         internal = false, $fn = 64);
        translate([0, 0, -0.01])
            cylinder(h = ring_h + 0.02, d = filter_clear_d);
        // slot for a small flat screwdriver (assembled from the body-cavity side)
        translate([0, 0, ring_h - 1.0])
            cube([fring_d + 2, 1.6, 2.2], center = true);
    }
}

lens_retainer();
