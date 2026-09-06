// mapscam receiver — the two rings.
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

// Top-hat: a Ø nose drops through the retainer thread onto the filter and holds it
// against the seat; the threaded body engages the stem's fring thread above.
// Authored z = 0 at the nose tip (which rests on the filter back face).
module filter_ring() {
    nose_d   = filter_pocket_d - 0.5;          // slides in the Ø8.6 pocket
    body_h   = fring_engage + 2.5;
    difference() {
        union() {
            cylinder(h = fring_nose_h + 0.2, d = nose_d, $fn = 40);
            translate([0, 0, fring_nose_h + body_h/2])
                threaded_rod(d = fring_d, l = body_h, pitch = fring_pitch,
                             internal = false, $fn = 48);
        }
        translate([0, 0, -1])
            cylinder(h = fring_nose_h + body_h + 2, d = filter_clear_d, $fn = 40);
        // slot for a small flat screwdriver (turned from the body-cavity side)
        translate([0, 0, fring_nose_h + body_h - 1.0])
            cube([fring_d + 3, 1.8, 2.4], center = true);
    }
}

lens_retainer();
