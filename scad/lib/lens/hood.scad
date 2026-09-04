// mapscam lens — round lens hood. Threads onto the front filter thread when the
// barrel has one, otherwise a friction slip-fit over the barrel OD.
//
// part = "hood" always renders it (even when hood_style = "none") so it can be
// printed on demand; the assembly preview only shows it when hood_style != "none".

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>

module hood() {
    threaded  = (filter_thread != "none");
    mount_d   = threaded ? filter_major : barrel_od_c;
    collar_h  = threaded ? filter_len + 1 : 6;
    outer_d   = mount_d + 2 * 2;          // 2 mm hood wall
    flare_d   = outer_d + 6;

    difference() {
        union() {
            cylinder(h = collar_h, d = outer_d);
            translate([0, 0, collar_h])
                cylinder(h = hood_length, d1 = outer_d, d2 = flare_d);
        }
        // mount interface
        if (threaded)
            translate([0, 0, collar_h / 2])
                threaded_rod(d = filter_major + 2 * 0.2, l = collar_h + 0.02,
                             pitch = filter_pitch, internal = true, $fn = 160);
        else
            translate([0, 0, -0.01])
                cylinder(h = collar_h + 0.02, d = mount_d + 0.35);
        // bore
        translate([0, 0, collar_h - 0.01])
            cylinder(h = hood_length + 0.02, d1 = mount_d, d2 = flare_d - 4);
    }
}

hood();
