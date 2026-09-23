// mapscam receiver — the two rings.
//   lens_retainer : threads into the barrel ahead of the Ø80 optic and clamps it
//                   back against the seat rim (same scheme as scad/lib/lens/retainer.scad).
//   filter_ring   : small threaded ring, clamps the 808 nm filter in the stem.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>
use <../threads.scad>

module lens_retainer() {
    difference() {
        // externally threaded ring — its flat rear face (z = 0) is the clamp face and
        // prints on the bed; print_thread's bottom bevel absorbs elephant's foot
        translate([0, 0, retainer_thk/2])
            print_thread(d = retainer_thread_d, l = retainer_thk, pitch = retainer_pitch);
        translate([0, 0, -1]) cylinder(h = retainer_thk + 2, d = clear_aperture_d);
        // two spanner notches in the front (outer) face
        for (a = [0, 90])
            rotate([0, 0, a]) translate([0, 0, retainer_thk - 1.0])
                cube([retainer_thread_d + 2, 2.0, 2.2], center = true);
    }
}

// Top-hat retainer for the Ø8.0 x 0.55 mm filter. Authored z = 0 at the nose tip.
// Screw it in from the body-cavity side: the Ø17 body threads into the stem's
// fring thread and its shoulder bottoms on the Ø17 -> Ø8.6 step exactly as the
// Ø8.1 nose meets the filter — so the filter is captured with no clamping stress
// and the thread carries full engagement. A flat screwdriver turns the top slot.
module filter_ring() {
    nose_d = filter_pocket_d - 0.5;            // slides in the Ø8.6 pocket
    body_h = fring_engage + 4.0;               // thread engagement + a slotted head above the boss
    difference() {
        union() {
            // nose, with a tip chamfer so it can't catch the filter edge
            cylinder(h = 0.8, d1 = nose_d - 1.6, d2 = nose_d, $fn = 40);
            translate([0, 0, 0.79])
                cylinder(h = fring_nose_h - 0.79 + 0.2, d = nose_d, $fn = 40);
            // threaded body
            translate([0, 0, fring_nose_h + body_h/2])
                // no bevel at the shoulder end — it is the depth stop (see above)
                print_thread(d = fring_d, l = body_h, pitch = fring_pitch, bevel1 = false);
        }
        translate([0, 0, -1])
            cylinder(h = fring_nose_h + body_h + 2, d = filter_clear_d, $fn = 40);
        // slot for a small flat screwdriver (turned from the body-cavity side)
        translate([0, 0, fring_nose_h + body_h - 1.0])
            cube([fring_d + 3, 1.8, 2.4], center = true);
    }
}

lens_retainer();
