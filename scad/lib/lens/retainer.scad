// mapscam lens — retainer ring: threads into the barrel ahead of the element
// group and clamps it back against the seat. Two spanner slots on the front face.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>

module retainer() {
    difference() {
        // externally threaded ring
        translate([0, 0, retainer_thk / 2])
            threaded_rod(d = retainer_thread_d,
                         l = retainer_thk,
                         pitch = retainer_pitch,
                         internal = false, $fn = 96);

        // clear bore
        translate([0, 0, -1])
            cylinder(h = retainer_thk + 2, d = clear_aperture_d);

        // two spanner slots in the front face
        for (a = [0, 90])
            rotate([0, 0, a])
                translate([0, 0, retainer_thk - 1.0])
                    cube([retainer_thread_d + 2, 1.6, 2.2], center = true);
    }
}

retainer();
